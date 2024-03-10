defmodule Punkix.Shop do
  @moduledoc """
  The Shop context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Punkix.Repo

  alias Punkix.Shop.Article

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  @spec list_articles() :: [Article.t()]
  def list_articles do
    Repo.all(Article)
  end

  @doc """
  Gets a single article.

  Returns {:error, :not_found} if the Article does not exist.

  ## Examples

      iex> get_article(123)
      %Article{}

      iex> get_article(456)
      ** {:error, :not_found}

  """
  @spec get_article(Article.id()) :: 
    {:ok, Article.t()} | {:error, :not_found}
  def get_article(id), do: Repo.fetch_one(Article, id)

  @doc """
  Creates a article.

  ## Examples

      iex> create_article("some name", "some description", "some schemas")
      {:ok, %Article{}}

      iex> create_article(nil, nil, nil)
      {:error, %Ecto.Changeset{}}

  """
  @spec create_article(String.t() | nil, String.t() | nil, String.t() | nil) :: 
    {:ok, Article.t()} | {:error, Ecto.Changeset.t()}
  def create_article(name, description, schemas) do
    %Article{}
    |> store_article(name, description, schemas)
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article.id, "some updated name", "some updated description", "some updated schemas")
      {:ok, %Article{}}

      iex> update_article(article.id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_article(Article.id(), String.t() | nil, String.t() | nil, String.t() | nil) :: 
    {:ok, Article.t()} | {:error, :not_found | Ecto.Changeset.t()}
  def update_article(article_id, name, description, schemas) do
    with {:ok, article} <- get_article(article_id) do
      store_article(article, name, description, schemas)
    end
  end

  @doc """
  Deletes a article.

  ## Examples

      iex> delete_article(article.id)
      {:ok, %Article{}}

      iex> delete_article(article.id)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_article(Article.id()) :: 
    {:ok, Article.t()} | {:error, :not_found | Ecto.Changeset.t()}
  def delete_article(article_id) do
    with {:ok, article} <- get_article(article_id) do
      Repo.delete(article)
    end
  end

  @doc false
  defp store_article(article, name, description, schemas) do
    article
    |> change(name: name, description: description, schemas: schemas)
    |> validate_required([:name, :description, :schemas])
    |> Repo.insert_or_update()
  end
end
