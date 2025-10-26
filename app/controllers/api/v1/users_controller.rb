class Api::V1::UsersController < Api::V1::BaseController
  # GET /api/v1/current_user
  def current
    render_success(
      current_user.as_json(
        only: [ :id, :email, :role, :created_at ],
        methods: [ :name ]
      )
    )
  end
end
