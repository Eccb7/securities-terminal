class ReactController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def index
    # This will render the React app
    render :index, layout: "react"
  end
end
