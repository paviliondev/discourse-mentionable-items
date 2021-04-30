class MentionableItems::AdminController < ::Admin::AdminController
  def index
    render_serialized(
      MentionableItems::Log.list(page: params[:page].to_i, filter: params[:filter]),
      MentionableItems::LogSerializer
    )
  end

  def import
    Jobs.enqueue(:import_mentionable_items)
    render json: success_json
  end
end