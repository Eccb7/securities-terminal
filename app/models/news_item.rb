class NewsItem < ApplicationRecord
  # Associations
  belongs_to :security, optional: true

  # Validations
  validates :title, presence: true
  validates :source, presence: true
  validates :published_at, presence: true

  # Scopes
  scope :recent, -> { order(published_at: :desc) }
  scope :for_security, ->(security_id) { where(security_id: security_id) }
  scope :since, ->(time) { where("published_at >= ?", time) }
  scope :today, -> { where("published_at >= ?", Time.current.beginning_of_day) }
  scope :with_tag, ->(tag) { where("tags @> ?", [ tag ].to_json) }

  # Instance methods
  def age
    return nil unless published_at
    Time.current - published_at
  end

  def age_in_words
    return nil unless published_at
    distance_of_time_in_words(published_at, Time.current)
  end

  def related_securities
    return [] unless tags
    Security.where(ticker: tags)
  end

  def add_tag(tag)
    self.tags ||= []
    self.tags << tag unless self.tags.include?(tag)
    save
  end

  def remove_tag(tag)
    return false unless tags
    self.tags.delete(tag)
    save
  end

  def snippet(length = 200)
    return nil unless body
    body.truncate(length, separator: " ")
  end
end
