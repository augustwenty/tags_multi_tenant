defmodule TagsMultiTenant.TagAs do
  defmacro __using__(model_context) do
    context = Atom.to_string(model_context)
    singularized_context = Inflex.singularize(context)

    quote do
      @before_compile unquote(__MODULE__)
      Module.register_attribute __MODULE__, :contexts, accumulate: true
      @contexts unquote(context)

      def unquote(:"add_#{singularized_context}")(struct, tag) when is_binary(tag) do
        TagsMultiTenant.add(struct, tag, unquote(context), [])
      end
      def unquote(:"add_#{singularized_context}")(struct, tag, opts) do
        TagsMultiTenant.add(struct, tag, unquote(context), opts)
      end

      def unquote(:"add_#{context}")(struct, tags) when not is_list(struct) do
        TagsMultiTenant.add(struct, tags, unquote(context), [])
      end
      def unquote(:"add_#{context}")(struct, tags, opts) do
        TagsMultiTenant.add(struct, tags, unquote(context), opts)
      end

      def unquote(:"remove_#{singularized_context}")(struct, tag) when is_binary(tag) do
        TagsMultiTenant.remove(struct, tag, unquote(context), [])
      end
      def unquote(:"remove_#{singularized_context}")(struct, tag, opts) do
        TagsMultiTenant.remove(struct, tag, unquote(context), opts)
      end

      def unquote(:"#{singularized_context}_list")(struct) do
        TagsMultiTenant.tag_list(struct, unquote(context), [])
      end
      def unquote(:"#{singularized_context}_list")(struct, opts) do
        TagsMultiTenant.tag_list(struct, unquote(context), opts)
      end

      def unquote(:"#{context}")() do
        TagsMultiTenant.tag_list(__MODULE__, unquote(context), [])
      end
      def unquote(:"#{context}")(opts) do
        TagsMultiTenant.tag_list(__MODULE__, unquote(context), opts)
      end

      def unquote(:"#{context}_queryable")() do
        TagsMultiTenant.tag_list_queryable(__MODULE__, unquote(context))
      end

      def unquote(:"tagged_with_#{singularized_context}")(tag) do
        TagsMultiTenant.tagged_with(tag, __MODULE__, unquote(context), [])
      end
      def unquote(:"tagged_with_#{singularized_context}")(tag, opts) do
        TagsMultiTenant.tagged_with(tag, __MODULE__, unquote(context), opts)
      end

      def unquote(:"tagged_with_#{context}")(tags) do
        TagsMultiTenant.tagged_with(tags, __MODULE__, unquote(context), [])
      end
      def unquote(:"tagged_with_#{context}")(tags, opts) do
        TagsMultiTenant.tagged_with(tags, __MODULE__, unquote(context), opts)
      end

      def unquote(:"tagged_with_query_#{singularized_context}")(queryable, tag) do
        TagsMultiTenant.tagged_with_query(queryable, tag, unquote(context))
      end

      def unquote(:"tagged_with_query_#{context}")(queryable, tags) do
        TagsMultiTenant.tagged_with_query(queryable, tags, unquote(context))
      end
    end
  end

  defmacro __before_compile__(_env) do

    quote do
      @contexts
      |> Enum.each(fn(context) ->
        singularized_context = Inflex.singularize(context)

        Module.eval_quoted(__MODULE__, quote do
          def unquote(:"add_#{context}")(tags) do
            TagsMultiTenant.add(%__MODULE__{}, tags, unquote(context), [])
          end
          def unquote(:"add_#{context}")(tags, opts) do
            TagsMultiTenant.add(%__MODULE__{}, tags, unquote(context), opts)
          end

          def unquote(:"add_#{singularized_context}")(tags) do
            TagsMultiTenant.add(%__MODULE__{}, tags, unquote(context), [])
          end
          def unquote(:"add_#{singularized_context}")(tags, opts) do
            TagsMultiTenant.add(%__MODULE__{}, tags, unquote(context), opts)
          end

          def unquote(:"remove_#{singularized_context}")(tag) do
            TagsMultiTenant.remove(%__MODULE__{}, tag, unquote(context), [])
          end
          def unquote(:"remove_#{singularized_context}")(tag, opts) do
            TagsMultiTenant.remove(%__MODULE__{}, tag, unquote(context), opts)
          end

          def unquote(:"rename_#{singularized_context}")(old_tag, new_tag) do
            TagsMultiTenant.rename(%__MODULE__{}, old_tag, new_tag, unquote(context), [])
          end
          def unquote(:"rename_#{singularized_context}")(old_tag, new_tag, opts) do
            TagsMultiTenant.rename(%__MODULE__{}, old_tag, new_tag, unquote(context), opts)
          end
        end)
      end)
    end

  end

end
