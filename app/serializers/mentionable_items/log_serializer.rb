class MentionableItems::LogSerializer < ::ApplicationSerializer
  attributes :type,
             :source,
             :message,
             :date

  def type
    I18n.t("mentionable_items.log.type.#{MentionableItems::Log.types.key(object.type).to_s}")
  end
end