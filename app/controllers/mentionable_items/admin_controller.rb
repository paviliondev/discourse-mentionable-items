class MentionableItems::AdminController < ::Admin::AdminController
  def index
    logs = MentionableItems::Log.list(page: params[:page].to_i, filter: params[:filter])

    render_json_dump(
      logs: ActiveModel::ArraySerializer.new(logs, each_serializer: MentionableItems::LogSerializer),
      info: MentionableItems.info
    )
  end

  def import
    Jobs.enqueue(:import_mentionable_items)
    render json: success_json
  end

  def destroy
    Jobs.enqueue(:destroy_mentionable_items)
    render json: success_json
  end
end