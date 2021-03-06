# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

#
# Snapshot(s) are intended to represent a snapshot of something in the system
# at a given point in time. The point in time is determined by the major and
# minor verison of the paper at the time of the snapshot.
#
# For example, after a paper is submitted several tasks are snapshotted. This
# lays the foundation for allowing users to view the history of those tasks as
# well to provide them a way to view differences between different versions
# of a task.
#
class Snapshot < ActiveRecord::Base
  include ViewableModel
  belongs_to :source, polymorphic: true
  belongs_to :paper

  validates :paper, presence: true
  validates :source, presence: true
  validates :major_version, presence: true
  validates :minor_version, presence: true

  after_initialize :set_key, if: :new_record?

  scope :attachments, -> { where(source_type: "Attachment") }
  scope :figures, -> { attachments.where("contents ->> 'name' = 'figure'") }
  scope :supporting_information_files, lambda {
    attachments.where("contents ->> 'name' = 'supporting-information-file'")
  }
  scope :adhoc_attachments, lambda {
    attachments.where("contents ->> 'name' = 'adhoc-attachment'")
  }

  def source=(new_source)
    super
    set_key
  end

  def get_property(name)
    contents["children"].find do |property|
      property["name"] == name
    end.try(:fetch, "value")
  end

  def sanitized_contents
    sanitize(contents)
  end

  private

  CHECK_FIELDS = ['id', 'owner_type', 'owner_id', 'grant_number', 'website', 'additional_comments', 'funder'].freeze
  IGNORE_FIELDS = [['name', 'type', 'value'], ['children', 'name', 'type']].freeze

  def sanitize(data)
    return data unless data.is_a?(Hash) || data.is_a?(Array)
    if data.is_a?(Array)
      return data if data.empty?
      data = data.select { |obj| !IGNORE_FIELDS.include?(obj.keys.sort) || !CHECK_FIELDS.include?(obj['name']) }
      data.map(&method(:sanitize))
    else
      data = data.except('id', 'answer_type')
      data.each do |key, value|
        data[key] = sanitize(value)
      end
    end
  end

  def set_key
    self.key = source.try(:snapshot_key)
  end
end
