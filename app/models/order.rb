class Order < ApplicationRecord
  belongs_to :user
  belongs_to :security
end
