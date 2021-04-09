class ::SiteSerializer
  attributes :mentionable_items

  def mentionable_items
    MentionableItem.all
  end
end
