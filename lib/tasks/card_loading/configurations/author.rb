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

# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class Author
    def self.name
      "Author"
    end

    def self.title
      "Author"
    end

    def self.content
      [
        {
          ident: "author--published_as_corresponding_author",
          value_type: "boolean",
          text: "This person should be identified as corresponding author on the published article"
        },

        {
          ident: "author--deceased",
          value_type: "boolean",
          text: "This person is deceased"
        },

        {
          ident: "author--contributions",
          value_type: "question-set",
          text: "Author Contributions",
          children: [
            {
              ident: "author--contributions--conceptualization",
              value_type: "boolean",
              text: "Conceptualization"
            },
            {
              ident: "author--contributions--investigation",
              value_type: "boolean",
              text: "Investigation"
            },
            {
              ident: "author--contributions--visualization",
              value_type: "boolean",
              text: "Visualization"
            },
            {
              ident: "author--contributions--methodology",
              value_type: "boolean",
              text: "Methodology"
            },
            {
              ident: "author--contributions--resources",
              value_type: "boolean",
              text: "Resources"
            },
            {
              ident: "author--contributions--supervision",
              value_type: "boolean",
              text: "Supervision"
            },
            {
              ident: "author--contributions--software",
              value_type: "boolean",
              text: "Software"
            },
            {
              ident: "author--contributions--data-curation",
              value_type: "boolean",
              text: "Data Curation"
            },
            {
              ident: "author--contributions--project-administration",
              value_type: "boolean",
              text: "Project Administration"
            },
            {
              ident: "author--contributions--validation",
              value_type: "boolean",
              text: "Validation"
            },
            {
              ident: "author--contributions--writing-original-draft",
              value_type: "boolean",
              text: "Writing - Original Draft"
            },
            {
              ident: "author--contributions--writing-review-and-editing",
              value_type: "boolean",
              text: "Writing - Review and Editing"
            },
            {
              ident: "author--contributions--funding-acquisition",
              value_type: "boolean",
              text: "Funding Acquisition"
            },
            {
              ident: "author--contributions--formal-analysis",
              value_type: "boolean",
              text: "Formal Analysis"
            }
          ]
        },

        {
          ident: "author--government-employee",
          value_type: "boolean",
          text: "Is this author an employee of the United States Government?"
        }
      ]
    end
  end
end
