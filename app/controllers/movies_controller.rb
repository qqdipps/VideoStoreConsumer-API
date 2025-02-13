class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory],
      ),
    )
  end

  def create
    if Movie.find_by(external_id: movie_params[:external_id])
      render(
        status: :conflict,
        json: { ok: false, errors: "Movie already exists in library" },
      )
    else
      movie = Movie.create(movie_params)
      render(
        status: :ok,
        json: movie.as_json(
          only: [:id, :title, :overview, :release_date, :inventory],
        ),
      )
    end
  end

  private

  def movie_params
    params.permit(:title, :overview, :release_date, :image_url, :inventory, :external_id)
  end

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
