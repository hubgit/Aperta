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

require 'rails/generators'
require "rails/generators/active_record"

module CustomCard
  class MigrationGenerator < ActiveRecord::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    # CustomCard::Configurations class name (CustomCard::Configurations::MyCard)
    argument :configuration, type: :string, required: true

    # legacy class name ("TahiStandardTasks::CoverLetterTask")
    argument :legacy_task_klass_name, type: :string, required: true

    def generate_custom_card_migration
      migration_template "migration.template", "db/migrate/#{file_name}.rb"
    end

    private

    def file_name
      migration_klass_name.underscore
    end

    def migration_klass_name
      "Migrate#{legacy_task_klass_name.demodulize}ToCustomCard"
    end
  end
end
