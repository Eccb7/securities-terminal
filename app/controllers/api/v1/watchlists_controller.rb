class Api::V1::WatchlistsController < Api::V1::BaseController
  before_action :set_watchlist, only: [ :show, :update, :destroy, :add_security, :remove_security ]

  def index
    @watchlists = policy_scope(Watchlist)
                    .includes(:watchlist_items)
                    .order(created_at: :desc)

    render json: {
      data: @watchlists.as_json(
        include: {
          watchlist_items: {
            only: [ :id, :security_id, :created_at ]
          }
        },
        methods: [ :securities_count ]
      )
    }
  end

  def show
    authorize @watchlist
    render json: {
      data: @watchlist.as_json(
        include: {
          watchlist_items: {
            include: {
              security: {
                only: [ :id, :symbol, :name, :security_type, :exchange_id ],
                include: {
                  latest_quote: {
                    only: [ :last_price, :change, :change_percent, :volume, :updated_at ]
                  },
                  exchange: {
                    only: [ :id, :name, :code ]
                  }
                }
              }
            }
          }
        },
        methods: [ :securities_count ]
      )
    }
  end

  def create
    @watchlist = current_user.watchlists.new(watchlist_params)
    authorize @watchlist

    if @watchlist.save
      render json: {
        data: @watchlist.as_json(methods: [ :securities_count ]),
        message: "Watchlist created successfully"
      }, status: :created
    else
      render json: {
        errors: @watchlist.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    authorize @watchlist

    if @watchlist.update(watchlist_params)
      render json: {
        data: @watchlist.as_json(methods: [ :securities_count ]),
        message: "Watchlist updated successfully"
      }
    else
      render json: {
        errors: @watchlist.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @watchlist

    if @watchlist.destroy
      render json: {
        message: "Watchlist deleted successfully"
      }
    else
      render json: {
        errors: @watchlist.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def add_security
    authorize @watchlist

    security = Security.find(params[:security_id])
    item = @watchlist.watchlist_items.new(security: security)

    if item.save
      render json: {
        data: item.as_json(
          include: {
            security: {
              only: [ :id, :symbol, :name, :security_type ],
              include: {
                latest_quote: {
                  only: [ :last_price, :change, :change_percent ]
                }
              }
            }
          }
        ),
        message: "Security added to watchlist"
      }, status: :created
    else
      render json: {
        errors: item.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def remove_security
    authorize @watchlist

    item = @watchlist.watchlist_items.find(params[:item_id])

    if item.destroy
      render json: {
        message: "Security removed from watchlist"
      }
    else
      render json: {
        errors: item.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_watchlist
    @watchlist = Watchlist.find(params[:id])
  end

  def watchlist_params
    params.require(:watchlist).permit(
      :name,
      :description
    )
  end
end
