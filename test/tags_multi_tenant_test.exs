defmodule TagsMultiTenantTest do
  alias Ecto.Adapters.SQL
  alias TagsMultiTenantPost, as: Post
  alias TagsMultiTenant.{Tagging, Tag}

  import Ecto.Query
  import Ecto.Query

  use ExUnit.Case

  @repo TagsMultiTenant.RepoClient.repo()
  @tenant_id "example_tenant"

  doctest TagsMultiTenant

  setup do
    # Regular test
    @repo.delete_all(Post)
    @repo.delete_all(Tagging)
    @repo.delete_all(Tag)

    # Multi tenant test
    setup_tenant()

    # on_exit(fn ->
    #   # Regular test
    #   @repo.delete_all(Post)
    #   @repo.delete_all(Tagging)
    #   @repo.delete_all(Tag)

    #   # Multi tenant test
    #   setup_tenant()
    # end)

    :ok
  end

  # Regular test
  test "add/4 with a tag returns the struct with the new tag" do
    post = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post, "mytag")

    result = TagsMultiTenant.add(post, "tag1")

    assert result.tags == ["mytag", "tag1"]
  end

  test "add/4 with a tag list returns the struct with the new tags" do
    post = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post, "mytag")

    result = TagsMultiTenant.add(post, ["tag1", "tag2"])

    assert result.tags == ["mytag", "tag1", "tag2"]
  end

  test "add/4 with context returns a diferent list for every context" do
    post = @repo.insert!(%Post{title: "hello world"})

    result1 = TagsMultiTenant.add(post, "mytag1", "context1")
    result2 = TagsMultiTenant.add(post, "mytag2", "context2")

    assert result1.context1 == ["mytag1"]
    assert result2.context2 == ["mytag2"]
  end

  test "add/4 with repeated tag returns the same tags" do
    post = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post, "mytag")

    result = TagsMultiTenant.add(post, "mytag")

    assert result.tags == ["mytag"]
  end

  test "add/4 with nil tag returns the same struct" do
    post = @repo.insert!(%Post{title: "hello world"})
    result = TagsMultiTenant.add(post, nil)
    assert result == post
  end

  test "remove/4 deletes a tag and returns a list of associated tags" do
    post = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post, "mytag")
    TagsMultiTenant.add(post, "mytag2")
    TagsMultiTenant.add(post, "mytag3")

    result = TagsMultiTenant.remove(post, "mytag2")

    assert result.tags == ["mytag", "mytag3"]
  end

  test "remove/4 deletes a tag for a specific context and returns a list of associated tags" do
    post = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post, "mytag", "context1")
    TagsMultiTenant.add(post, "mytag2", "context1")
    TagsMultiTenant.add(post, "mytag3", "context2")

    result = TagsMultiTenant.remove(post, "mytag2", "context1")

    assert result.context1 == ["mytag"]
  end

  test "remove/4 does nothing for an unexistent tag" do
    post = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post, "mytag")
    TagsMultiTenant.add(post, "mytag2")
    TagsMultiTenant.add(post, "mytag3")

    result = TagsMultiTenant.remove(post, "my2")

    assert result.tags == ["mytag", "mytag2", "mytag3"]
  end

  test "tag_list/2 with struct as param returns a list of associated tags" do
    post = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post, "mytag")
    TagsMultiTenant.add(post, "mytag2")

    result = TagsMultiTenant.tag_list(post)

    assert result == ["mytag", "mytag2"]
  end

  test "tag_list/2 with struct returns a list of associated tags for a specific context" do
    post = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post, "mytag", "context")
    TagsMultiTenant.add(post, "mytag2", "context")

    result = TagsMultiTenant.tag_list(post, "context")

    assert result == ["mytag", "mytag2"]
  end

  test "tag_list/2 with module as param returns a list of tags related with one context and module" do
    post1 = @repo.insert!(%Post{title: "hello world"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    TagsMultiTenant.add(post1, ["tag1", "tag2"])
    TagsMultiTenant.add(post2, ["tag2", "tag3"])

    result = TagsMultiTenant.tag_list(Post)

    assert Enum.count(result) == 3
    assert Enum.sort(result) == Enum.sort(["tag1", "tag2", "tag3"])
  end

  test "should return all posts when empty tag passed in" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "tagged2")

    result = TagsMultiTenant.tagged_with("", Post)

    assert Enum.count(result) == 3
    assert Enum.sort(result) == Enum.sort([post1, post2, post3])
  end

  test "should return all posts, ignoring invalid tag passed in" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "tagged2")

    result = TagsMultiTenant.tagged_with(":", Post)

    assert Enum.count(result) == 3
    assert Enum.sort(result) == Enum.sort([post1, post2, post3])
  end

  test "should return all posts, ignoring invalid tag, begins action" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "tagged2")

    result = TagsMultiTenant.tagged_with("begins:", Post)

    assert Enum.count(result) == 3
    assert Enum.sort(result) == Enum.sort([post1, post2, post3])
  end

  test "should return filtered posts, begins action, including dash" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "dash-dash")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "tagged2")

    result = TagsMultiTenant.tagged_with("begins:dash-dash", Post)

    assert Enum.count(result) == 1
    assert Enum.sort(result) == Enum.sort([post1])
  end

  test "should return all posts, ignoring invalid tag, ends action" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "tagged2")

    result = TagsMultiTenant.tagged_with("ends:", Post)

    assert Enum.count(result) == 3
    assert Enum.sort(result) == Enum.sort([post1, post2, post3])
  end

  test "should return all posts, ignoring invalid tag, contains action" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "tagged2")

    result = TagsMultiTenant.tagged_with("contains:", Post)

    assert Enum.count(result) == 3
    assert Enum.sort(result) == Enum.sort([post1, post2, post3])
  end

  test "should return all posts, ignoring invalid tag, equals action" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "tagged2")

    result = TagsMultiTenant.tagged_with("equals:", Post)

    assert Enum.count(result) == 3
    assert Enum.sort(result) == Enum.sort([post1, post2, post3])
  end

  test "tagged_with returns proper list of structs associated to an begins tag" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "dog2")

    result = TagsMultiTenant.tagged_with("begins:tag", Post)

    assert Enum.count(result) == 2
    assert Enum.member?(result, post1)
    assert Enum.member?(result, post2)
  end

  test "tagged_with returns proper list of structs associated to an ends tag" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "dog1")

    result = TagsMultiTenant.tagged_with(["ends:dog1"], Post)

    assert Enum.count(result) == 1
    assert Enum.member?(result, post3)
  end

  test "tagged_with returns proper list of structs associated to an equals tag" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "tagged2")

    result = TagsMultiTenant.tagged_with("equals:tagged1", Post)

    assert Enum.count(result) == 2
    assert Enum.member?(result, post1)
    assert Enum.member?(result, post2)
  end

  test "tagged_with returns proper list of structs associated to a contains tag" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, "tagged1")
    TagsMultiTenant.add(post3, "tagged2")

    result = TagsMultiTenant.tagged_with("contains:gg", Post)

    assert Enum.count(result) == 3
    assert Enum.member?(result, post1)
    assert Enum.member?(result, post2)
    assert Enum.member?(result, post3)
  end

  test "tagged_with_query returns a query of structs equals" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world1"})
    post3 = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, ["tagged1", "tagged2"])
    TagsMultiTenant.add(post3, "tagged2")
    query = Post |> where(title: "hello world1")

    result = TagsMultiTenant.tagged_with_query(query, ["equals:tagged1"]) |> @repo.all

    assert Enum.count(result) == 2
    assert Enum.member?(result, post1)
    assert Enum.member?(result, post2)
  end

  test "tagged_with_query returns a query of structs begins with" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world1"})
    post3 = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, ["tagged1", "tagged2"])
    TagsMultiTenant.add(post3, "tagged2")
    query = Post |> where(title: "hello world1")

    result = TagsMultiTenant.tagged_with_query(query, ["begins:tagged"]) |> @repo.all

    assert Enum.count(result) == 2
    assert Enum.member?(result, post1)
    assert Enum.member?(result, post2)
  end

  test "tagged_with_query returns a query of structs ends with" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world1"})
    post3 = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, ["tagged1", "tagged2"])
    TagsMultiTenant.add(post3, "tagged2")
    query = Post |> where(title: "hello world1")

    result = TagsMultiTenant.tagged_with_query(query, ["ends:ged1"]) |> @repo.all

    assert Enum.count(result) == 2
    assert Enum.member?(result, post1)
    assert Enum.member?(result, post2)
  end

  test "tagged_with_query returns a query of structs like" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world1"})
    post3 = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, ["tagged1", "tagged2"])
    TagsMultiTenant.add(post3, "tagged2")
    query = Post |> where(title: "hello world1")

    result = TagsMultiTenant.tagged_with_query(query, ["like:ged1"]) |> @repo.all

    assert Enum.count(result) == 2
    assert Enum.member?(result, post1)
    assert Enum.member?(result, post2)
  end

  test "tagged_with_query/4 returns a query of structs associated to a tag" do
    post1 = @repo.insert!(%Post{title: "hello world1"})
    post2 = @repo.insert!(%Post{title: "hello world2"})
    post3 = @repo.insert!(%Post{title: "hello world3"})
    TagsMultiTenant.add(post1, "tagged1")
    TagsMultiTenant.add(post2, ["tagged1", "tagged2"])
    TagsMultiTenant.add(post3, "tagged2")
    query = Post |> where(title: "hello world2")

    result = TagsMultiTenant.tagged_with_query(query, ["contains:tag"]) |> @repo.all

    assert result == [post2]
  end

  # Multi tenant test
  test "[multi tenant] add/4 with a tag returns the struct with the new tag" do
    post = @repo.insert!(%Post{title: "hello world"})
    TagsMultiTenant.add(post, "mytag")

    result = TagsMultiTenant.add(post, "tag1")

    assert result.tags == ["mytag", "tag1"]
  end

  test "[multi tenant] add/4 with a tag list returns the struct with the new tags" do
    post = @repo.insert!(%Post{title: "hello world"}, prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag", prefix: @tenant_id)

    result = TagsMultiTenant.add(post, ["tag1", "tag2"], prefix: @tenant_id)

    assert result.tags == ["mytag", "tag1", "tag2"]
  end

  test "[multi tenant] add/4 with context returns a diferent list for every context" do
    post = @repo.insert!(%Post{title: "hello world"}, prefix: @tenant_id)

    result1 = TagsMultiTenant.add(post, "mytag1", "context1", prefix: @tenant_id)
    result2 = TagsMultiTenant.add(post, "mytag2", "context2", prefix: @tenant_id)

    assert result1.context1 == ["mytag1"]
    assert result2.context2 == ["mytag2"]
  end

  test "[multi tenant] add/4 with repeated tag returns the same tags" do
    post = @repo.insert!(%Post{title: "hello world"}, prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag", prefix: @tenant_id)

    result = TagsMultiTenant.add(post, "mytag", prefix: @tenant_id)

    assert result.tags == ["mytag"]
  end

  test "[multi tenant] add/4 with nil tag returns the same struct" do
    post = @repo.insert!(%Post{title: "hello world"}, prefix: @tenant_id)
    result = TagsMultiTenant.add(post, nil, prefix: @tenant_id)
    assert result == post
  end

  test "[multi tenant] remove/4 deletes a tag and returns a list of associated tags" do
    post = @repo.insert!(%Post{title: "hello world"}, prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag", "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag2", "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag3", "tags", prefix: @tenant_id)

    result = TagsMultiTenant.remove(post, "mytag2", "tags", prefix: @tenant_id)

    assert result.tags == ["mytag", "mytag3"]
  end

  test "[multi tenant] remove/4 deletes a tag for a specific context and returns a list of associated tags" do
    post = @repo.insert!(%Post{title: "hello world"}, prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag", "context1", prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag2", "context1", prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag3", "context2", prefix: @tenant_id)

    result = TagsMultiTenant.remove(post, "mytag2", "context1", prefix: @tenant_id)

    assert result.context1 == ["mytag"]
  end

  test "[multi tenant] remove/4 does nothing for an unexistent tag" do
    post = @repo.insert!(%Post{title: "hello world"}, prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag", "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag2", "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag3", "tags", prefix: @tenant_id)

    result = TagsMultiTenant.remove(post, "my2", "tags", prefix: @tenant_id)

    assert result.tags() == ["mytag", "mytag2", "mytag3"]
  end

  test "[multi tenant] tag_list/2 with struct as param returns a list of associated tags" do
    post = @repo.insert!(%Post{title: "hello world"}, prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag", "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag2", "tags", prefix: @tenant_id)

    result = TagsMultiTenant.tag_list(post, "tags", prefix: @tenant_id)

    assert result == ["mytag", "mytag2"]
  end

  test "[multi tenant] tag_list/2 with struct returns a list of associated tags for a specific context" do
    post = @repo.insert!(%Post{title: "hello world"}, prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag", "context", prefix: @tenant_id)
    TagsMultiTenant.add(post, "mytag2", "context", prefix: @tenant_id)

    result = TagsMultiTenant.tag_list(post, "context", prefix: @tenant_id)

    assert result == ["mytag", "mytag2"]
  end

  test "[multi tenant] tag_list/2 with module as param returns a list of tags related with one context and module" do
    post1 = @repo.insert!(%Post{title: "hello world"}, prefix: @tenant_id)
    post2 = @repo.insert!(%Post{title: "hello world2"}, prefix: @tenant_id)
    TagsMultiTenant.add(post1, ["tag1", "tag2"], "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post2, ["tag2", "tag3"], "tags", prefix: @tenant_id)

    result = TagsMultiTenant.tag_list(Post, "tags", prefix: @tenant_id)

    assert result == ["tag1", "tag2", "tag3"]
  end

  test "[multi tenant] tagged_with/4 returns a list of structs associated to a tag" do
    post1 = @repo.insert!(%Post{title: "hello world1"}, prefix: @tenant_id)
    post2 = @repo.insert!(%Post{title: "hello world2"}, prefix: @tenant_id)
    post3 = @repo.insert!(%Post{title: "hello world3"}, prefix: @tenant_id)
    TagsMultiTenant.add(post1, "tagged1", "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post2, "tagged1", "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post3, "tagged2", "tags", prefix: @tenant_id)
    post1 = @repo.get(Post, 1, prefix: @tenant_id)
    post2 = @repo.get(Post, 2, prefix: @tenant_id)

    result = TagsMultiTenant.tagged_with("equals:tagged1", Post, "tags", prefix: @tenant_id)

    assert result == [post1, post2]
  end

  test "[multi tenant] tagged_with returns a list of structs associated list of tags" do
    post1 = @repo.insert!(%Post{title: "hello world1"}, prefix: @tenant_id)
    post2 = @repo.insert!(%Post{title: "hello world2"}, prefix: @tenant_id)
    post3 = @repo.insert!(%Post{title: "hello world3"}, prefix: @tenant_id)
    TagsMultiTenant.add(post1, "tagged1", "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post2, "dog", "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post3, "tagged2", "tags", prefix: @tenant_id)
    post1 = @repo.get(Post, 1, prefix: @tenant_id)
    post2 = @repo.get(Post, 2, prefix: @tenant_id)

    result =
      TagsMultiTenant.tagged_with(["equals:tagged1", "ends:dog"], Post, "tags", prefix: @tenant_id)

    assert Enum.count(result) == 2
    assert Enum.sort(result) == Enum.sort([post1, post2])
  end

  test "[multi tenant] tagged_with_query/4 returns a query of structs associated to a tag" do
    post1 = @repo.insert!(%Post{title: "hello world1"}, prefix: @tenant_id)
    post2 = @repo.insert!(%Post{title: "hello world2"}, prefix: @tenant_id)
    post3 = @repo.insert!(%Post{title: "hello world3"}, prefix: @tenant_id)
    TagsMultiTenant.add(post1, "tagged1", "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post2, ["tagged1", "tagged2"], "tags", prefix: @tenant_id)
    TagsMultiTenant.add(post3, "tagged2", "tags", prefix: @tenant_id)
    query = Post |> where(title: "hello world2")
    post2 = @repo.get(Post, 2, prefix: @tenant_id)

    result =
      TagsMultiTenant.tagged_with_query(query, ["tagged1", "tagged2"])
      |> @repo.all(prefix: @tenant_id)

    assert result == [post2]
  end

  # Aux functions
  defp setup_tenant do
    migrations_path = Application.app_dir(:tags_multi_tenant, ["priv", "repo", "migrations"])

    # Drop the previous tenant to reset the data
    SQL.query(@repo, "DROP SCHEMA \"#{@tenant_id}\" CASCADE", [])

    # Create new tenant
    SQL.query(@repo, "CREATE SCHEMA \"#{@tenant_id}\"", [])
    Ecto.Migrator.run(@repo, migrations_path, :up, prefix: @tenant_id, all: true)
  end
end
