defmodule TagsMultiTenant.TagsMultiTenantQuery do
  import Ecto.{Query}
  alias Makeup.Styles.HTML.IgorStyle
  alias TagsMultiTenant.{Tagging, Tag}

  @moduledoc """
  Allow to build essential ecto queries for tags_multi_tenant

  All this functions only should be used from TagsMultiTenant module
  """

  @doc """
  Build the query to search tags in a specific context, struct or module
  """
  def search_tags(context, taggable_type, taggable_id \\ nil) do
    Tag
    |> join_taggings_from_tag(context, taggable_type, taggable_id)
    |> join_tags
    |> distinct([tags: tags], tags.name)
    |> order_by([taggings: taggings], asc: taggings.inserted_at)
    |> select([tags: tags], tags.name)
  end

  defp join_taggings_from_tag(query, context, taggable_type, nil) do
    query
    |> join(:inner, [tag], tg in Tagging,
      as: :taggings,
      on:
        tag.id == tg.tag_id and
          tg.taggable_type == ^taggable_type and
          tg.context == ^context
    )
  end

  defp join_taggings_from_tag(query, context, taggable_type, taggable_id) do
    query
    |> join(:inner, [tag], tg in Tagging,
      as: :taggings,
      on:
        tag.id == tg.tag_id and
          tg.taggable_type == ^taggable_type and
          tg.context == ^context and
          tg.taggable_id == ^taggable_id
    )
  end

  @tag_format ~r/^(begins|ends|contains|equals):(\w+)$/

  defp split_action_value(tag = [_head | _tail = []]) do
    with tag when not is_nil(tag) <- Regex.run(@tag_format, Enum.at(tag, 0, []), capture: :first) do
      split = String.split(Enum.at(tag, 0, []), ":", trim: true)
      action = Enum.at(split, 0, nil)
      value = Enum.at(split, 1, nil)

      {:ok, action, value}
    else
      _ ->
        {:error, "incorrect format passed"}
    end
  end

  defp create_where(action, value)

  defp create_where("begins", value) when byte_size(value) > 0 do
    like = "#{value}%"
    dynamic([tags: tags], ilike(tags.name, ^like))
  end

  defp create_where("ends", value) when byte_size(value) > 0 do
    like = "%#{value}"
    dynamic([tags: tags], ilike(tags.name, ^like))
  end

  defp create_where("contains", value) when byte_size(value) > 0 do
    like = "%#{value}%"
    dynamic([tags: tags], ilike(tags.name, ^like))
  end

  defp create_where("equals", value) when byte_size(value) > 0 do
    IO.inspect("HERE")
    dynamic([tags: tags], tags.name == ^value)
  end

  defp create_where(_, _) do
    true
  end

  defp build_single(tag = [_head | _tail = []]) do
    with {:ok, action, value} <- split_action_value(tag) do
      create_where(action, value)
    else
      {:error, message} ->
        IO.inspect(message)
        true

      _ ->
        true
    end
  end

  defp build_where([head | tail]) do
    condition1 = build_single([head])

    Enum.reduce(tail, condition1, fn tag, conditions ->
      build_or_where([tag], conditions)
    end)
  end

  defp create_or_where(action, value, conditions)

  defp create_or_where("begins", value, conditions) when byte_size(value) > 0 do
    IO.inspect("1")
    like = "#{value}%"
    dynamic([tags: tags], ^conditions or ilike(tags.name, ^like))
  end

  defp create_or_where("ends", value, conditions) when byte_size(value) > 0 do
    IO.inspect("2")
    like = "%#{value}"
    dynamic([tags: tags], ^conditions or ilike(tags.name, ^like))
  end

  defp create_or_where("contains", value, conditions) when byte_size(value) > 0 do
    IO.inspect("3")
    like = "%#{value}%"
    dynamic([tags: tags], ^conditions or ilike(tags.name, ^like))
  end

  defp create_or_where("equals", value, conditions) when byte_size(value) > 0 do
    IO.inspect("4")
    dynamic([tags: tags], ^conditions or tags.name == ^value)
  end

  defp create_or_where(_, _, _) do
    IO.inspect("5")
    true
  end

  defp build_or_where(tag = [_head | _tail = []], conditions) do
    with {:ok, action, value} <- split_action_value(tag) do
      IO.inspect("INSIDE")
      IO.inspect(action)
      IO.inspect(value)
      create_or_where(action, value, conditions)
    else
      {:error, message} ->
        IO.inspect("ERROR1")
        IO.inspect(message)
        conditions

      _ ->
        IO.inspect("ERROR2")
        conditions
    end
  end

  @doc """
  Build the query to search tagged resources
  """
  def search_tagged_with(query, tags, context, taggable_type) do
    # tags_length = length(tags)

    conditions = build_where(tags)

    IO.inspect("SEARCH")

    IO.inspect(conditions)

    query
    |> join_taggings_from_model(context, taggable_type)
    |> join_tags
    # |> where([tags: tags], tags.name in ^tags)
    # |> build_where(tags)
    |> where(^conditions)
    |> group_by([m], m.id)
    # |> having([taggings: taggings], count(taggings.taggable_id) <= ^tags_length)
    |> order_by([m], asc: m.inserted_at)
    |> select([m], m)
    |> IO.inspect()
  end

  @doc """
  Build the query to get all Tags of a tag_resource and context.
  """
  def get_tags_association(struct, tag_resource, context) do
    taggable_type =
      struct.__struct__
      |> Module.split()
      |> List.last()

    case struct.id do
      nil -> get_all_tags(tag_resource, taggable_type, context)
      _ -> get_only_tags_related(tag_resource, taggable_type, struct.id, context)
    end
  end

  def count_tagging_by_tag_id(tag_id) do
    Tagging
    |> where([t], t.tag_id == ^tag_id)
    |> select([m], count(m.id))
  end

  # Get ALL Tags related to context and taggable_type
  defp get_all_tags(tag_resource, taggable_type, context) do
    Tagging
    |> where(
      [tag],
      tag.tag_id == ^tag_resource.id and
        tag.taggable_type == ^taggable_type and
        tag.context == ^context
    )
  end

  # Get only the tags related to a taggable_id
  defp get_only_tags_related(tag_resource, taggable_type, taggable_id, context) do
    tag_resource
    |> get_all_tags(taggable_type, context)
    |> where([tag], tag.taggable_id == ^taggable_id)
  end

  defp join_taggings_from_model(query, context, taggable_type) do
    if has_named_binding?(query, :taggings) do
      query
    else
      query
      |> join(:inner, [m], t in Tagging,
        as: :taggings,
        on: t.taggable_type == ^taggable_type and t.context == ^context and m.id == t.taggable_id
      )
    end
  end

  defp join_tags(query) do
    if has_named_binding?(query, :tags) do
      query
    else
      query
      |> join(:inner, [taggings: taggings], t in Tag, as: :tags, on: t.id == taggings.tag_id)
    end
  end
end
