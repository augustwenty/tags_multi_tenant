# TagsMultiTenant

TagsMultiTenant allows you to manage tags associated to your records.

It also allows you to specify various contexts

## Installation

  1. Add `tags_multi_tenant` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:tags_multi_tenant, "~> 0.1.4"}]
  end
  ```

  2. Configure TagsMultiTenant to use your repo in `config/config.exs`:

  ```elixir
  # Options
  # taggable_id - This field is default :integer, but you can set it as :uuid

  config :tags_multi_tenant,
    repo: ApplicationName.Repo,
    taggable_id: :uuid
  ```

  3. Install your dependencies:

  ```
  mix deps.get
  ```

  4. Generate the migrations:

  ```
  mix TagsMultiTenant.install
  ```
  
  This will create two migration files, xxxxx\_create\_tag.exs and xxxxx\_create\_tagging.exs.  You can leave    these in the repo/migrations directory if you are
	
	* you are not using a multi-tenant database
  	* you are using a multi-tenant database, but prefer to leave the tagging in the 'public' schema

  If you prefer to use the multi-tenant features, you will need to move the two migration files to the ```tenant_migrations``` directory prior to running the ```mix ecto.migrate```

  5. Run the migrations:

  ```
  mix ecto.migrate
  ```
  
  If you are using the Triplex package to manage multi-tenant migrations, you can use 
  
  ```
  mix triplex.migrate
  ``` 
  to migrate these migrations.

## Include it in your models

Now, you can use the library in your models.

You should add the next line to your taggable model:

`use TagsMultiTenant.TagAs, :tag_context_name`

i.e.:

  ```elixir
  defmodule Post do
    use Ecto.Schema
    use TagsMultiTenant.TagAs, :tags
    use TagsMultiTenant.TagAs, :categories

    import Ecto.Changeset

    schema "posts" do
      field :title, :string
      field :body, :boolean

      timestamps()
    end

    def changeset(struct, params \\ %{}) do
      struct
      |> cast(params, [:title, :body])
      |> validate_required([:title])
    end
  end
  ```
As you can see, we have included two different contexts, tags and
categories

Now we can use a set of metaprogrammed functions:

`Post.add_category(struct, tag)` - Passing a persisted struct will
allow you to associate a new tag

`Post.add_categories(struct, tags)` - Passing a persisted struct will
allow you to associate a new list of tags

`Post.add_category(tag)` - Add a Tag without associate it to a persisted struct,
this allow you have tags availables in the context. Example using `Post.categories`

`Post.remove_category(struct, tag)` - Will allow you to remove the relation `struct - tag`,
but the tag will persist.

`Post.remove_category(tag)` - Will allow you to remove a tag in the context `Post - category`. Tag and relations with Post will be deleted.

`Post.rename_category(old_tag, new_tag)` - Will allow you to rename the tag name.

`Post.categories_list(struct)` - List all associated tags with the given
struct

`Post.categories` - List all associated tags with the module

`Post.categories_queryable` - Same as `Post.categories` but it returns a `queryable` instead of a list.

`Post.tagged_with_category(tag)` - Search for all resources tagged with
the given tag

`Post.tagged_with_categories(tags)` - Search for all resources tagged
with the given list tag

`Post.tagged_with_query_category(queryable, tags)` - Allow to
concatenate ecto queries and return the query.

`Post.tagged_with_query_categories(queryable, tags)` - Same than previous function but allow to receive a list of tags


## Working with functions

If you want you can use directly a set of functions to play with tags:

[`TagsMultiTenant.add/4`](https://hexdocs.pm/tags_multi_tenant/TagsMultiTenant.html#add/4)

[`TagsMultiTenant.remove/4`](https://hexdocs.pm/tags_multi_tenant/TagsMultiTenant.html#remove/4)

[`TagsMultiTenant.rename/5`](https://hexdocs.pm/tags_multi_tenant/TagsMultiTenant.html#rename/5)

[`TagsMultiTenant.tag_list/3`](https://hexdocs.pm/tags_multi_tenant/TagsMultiTenant.html#tag_list/3)

[`TagsMultiTenant.tag_list_queryable/2`](https://hexdocs.pm/tags_multi_tenant/TagsMultiTenant.html#tag_list_queryable/2)

[`TagsMultiTenant.tagged_with/4`](https://hexdocs.pm/tags_multi_tenant/TagsMultiTenant.html#tagged_with/4)

[`TagsMultiTenant.tagged_with_query/3`](https://hexdocs.pm/tags_multi_tenant/TagsMultiTenant.html#tagged_with_query/3)
