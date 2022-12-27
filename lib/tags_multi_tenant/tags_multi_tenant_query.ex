defmodule TagsMultiTenant.TagsMultiTenantQuery do
  import Ecto.{Query}
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

  @doc """
  Build the query to search tagged resources
  """
  def search_tagged_with(query, tags, context, taggable_type) do
    IO.inspect("------------------------")
    tags_length = length(tags)

    query
    |> join_taggings_from_model(context, taggable_type)
    |> IO.inspect()
    |> join_tags
    |> IO.inspect()
    |> where([tags: tags], tags.name in ^tags)
    |> IO.inspect()
    |> group_by([m], m.id)
    |> having([taggings: taggings], count(taggings.taggable_id) == ^tags_length)
    |> order_by([m], asc: m.inserted_at)
    |> select([m], m)
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
