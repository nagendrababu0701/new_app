class Project < ApplicationRecord
 belongs_to :user
 validates_presence_of :project_name, :db_name,:env
 #validates_format_of :project_name, with: /\A[a-zA-Z]+\s[a-zA-Z]+$/i
end
