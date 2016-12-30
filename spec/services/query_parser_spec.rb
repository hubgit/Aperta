# rubocop:disable Metrics/LineLength, Style/StringLiterals
# I'm disabling line-length in this file because it consists almost
# entirely of long strings where extra whitespace is deadly.

require 'rails_helper'

module QueryParserSpec
  class FictionalReport < TahiStandardTasks::ReviewerReportTask
  end
end

describe QueryParser do
  describe '#parse' do
    describe 'paper metadata queries' do
      it 'parses type queries' do
        parse = QueryParser.new.parse 'TYPE IS research'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."paper_type" ILIKE 'research'
        SQL
      end

      it 'parses type NOT queries' do
        parse = QueryParser.new.parse 'TYPE IS NOT research'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."paper_type" NOT ILIKE 'research'
        SQL
      end

      it 'parses decision queries when the decision IS' do
        parse = QueryParser.new.parse 'DECISION IS major revision'
        expect(parse.to_sql).to eq(<<-SQL.strip_heredoc.chomp)
          "papers"."id" IN (SELECT decisions_0.paper_id from (SELECT paper_id, MAX("decisions"."registered_at") AS registered_at FROM "decisions" WHERE "decisions"."registered_at" IS NOT NULL AND "decisions"."rescinded" != 't' GROUP BY paper_id)
              AS decisions_0
          INNER JOIN decisions ON
              decisions.paper_id = decisions_0.paper_id
              AND decisions.registered_at = decisions_0.registered_at
          WHERE
          "decisions"."verdict" = 'major_revision')
        SQL
      end

      it 'parses decision queries when the decision IS NOT' do
        parse = QueryParser.new.parse 'DECISION IS NOT major revision'
        expect(parse.to_sql).to eq(<<-SQL.strip_heredoc.chomp)
          "papers"."id" IN (SELECT decisions_0.paper_id from (SELECT paper_id, MAX("decisions"."registered_at") AS registered_at FROM "decisions" WHERE "decisions"."registered_at" IS NOT NULL AND "decisions"."rescinded" != 't' GROUP BY paper_id)
              AS decisions_0
          INNER JOIN decisions ON
              decisions.paper_id = decisions_0.paper_id
              AND decisions.registered_at = decisions_0.registered_at
          WHERE
          "decisions"."verdict" != 'major_revision')
        SQL
      end

      it 'parses status queries' do
        parse = QueryParser.new.parse 'STATUS IS submitted'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."publishing_state" = 'submitted'
        SQL
      end

      it 'parses raw title queries' do
        parse = QueryParser.new.parse 'composite abuse scale'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          to_tsvector('english', "papers"."title") @@ to_tsquery('english', 'composite&abuse&scale')
        SQL
      end

      it 'parses raw title queries with extra spaces' do
        parse = QueryParser.new.parse ' composite abuse     scale '
        expect(parse.to_sql).to eq(<<-SQL.strip)
          to_tsvector('english', "papers"."title") @@ to_tsquery('english', 'composite&abuse&scale')
        SQL
      end

      it 'parses raw title queries with special whitespace characters' do
        parse = QueryParser.new.parse "composite\tabuse\n scale \r\f"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          to_tsvector('english', "papers"."title") @@ to_tsquery('english', 'composite&abuse&scale')
        SQL
      end

      it 'parses framed title queries' do
        q = 'TITLE IS composite abuse scale (AND other things)'
        parse = QueryParser.new.parse q
        expect(parse.to_sql).to eq(<<-SQL.strip)
          to_tsvector('english', "papers"."title") @@ to_tsquery('english', 'composite&abuse&scale&(AND&other&things)')
        SQL
      end

      it 'parses raw doi queries' do
        parse = QueryParser.new.parse '1241251'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."doi" ILIKE '%1241251%'
        SQL
      end

      it 'parses framed doi queries' do
        parse = QueryParser.new.parse 'DOI IS 1241251'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."doi" ILIKE '%1241251%'
        SQL
      end

      it 'parses OR statements' do
        parse = QueryParser.new.parse 'STATUS IS rejected OR STATUS IS withdrawn'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          ("papers"."publishing_state" = 'rejected' OR "papers"."publishing_state" = 'withdrawn')
        SQL
      end

      it 'parses AND statements' do
        parse = QueryParser.new.parse 'STATUS IS rejected AND TYPE IS research'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."publishing_state" = 'rejected' AND "papers"."paper_type" ILIKE 'research'
        SQL
      end

      it 'parses parenthetical statements' do
        q = 'TYPE IS research AND (STATUS IS rejected OR STATUS IS withdrawn)'
        parse = QueryParser.new.parse q
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."paper_type" ILIKE 'research' AND ("papers"."publishing_state" = 'rejected' OR "papers"."publishing_state" = 'withdrawn')
        SQL
      end

      it 'parses STATUS IS NOT statements' do
        parse = QueryParser.new.parse 'STATUS IS NOT unsubmitted'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."publishing_state" != 'unsubmitted'
        SQL
      end
    end

    describe 'task queries' do
      it 'parses TASK x IS COMPLETE' do
        parse = QueryParser.new.parse 'TASK anytask IS COMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed" = 't'
        SQL
      end

      it 'parses TASK x IS INCOMPLETE' do
        parse = QueryParser.new.parse 'TASK anytask IS INCOMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed" = 'f'
        SQL
      end

      it 'parses TASK x IS NOT COMPLETE' do
        parse = QueryParser.new.parse 'TASK anytask IS NOT COMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed" = 'f'
        SQL
      end

      it 'parses HAS TASK x' do
        parse = QueryParser.new.parse 'HAS TASK anytask'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask'
        SQL
      end

      it 'parses HAS NO TASK x' do
        parse = QueryParser.new.parse 'HAS NO TASK anytask'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."id" NOT IN (SELECT paper_id FROM "tasks" WHERE "tasks"."title" ILIKE 'anytask')
        SQL
      end

      it 'parses ANDed TASK queries as multiple joins' do
        query = 'TASK anytask IS COMPLETE AND TASK someothertask IS INCOMPLETE'
        parse = QueryParser.new.parse query
        expect(parse.to_sql).to eq(<<-SQL.strip)
           "tasks_0"."title" ILIKE 'anytask' AND "tasks_0"."completed" = 't' AND "tasks_1"."title" ILIKE 'someothertask' AND "tasks_1"."completed" = 'f'
        SQL
      end

      it 'parses TASK x HAS OPEN INVITATIONS' do
        parse = QueryParser.new.parse 'TASK anytask HAS OPEN INVITATIONS'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask' AND "invitations_1"."state" IN ('pending', 'invited')
        SQL
      end

      it 'parses TASK x HAS NO OPEN INVITATIONS' do
        parse = QueryParser.new.parse 'TASK anytask HAS NO OPEN INVITATIONS'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."title" ILIKE 'anytask' AND "invitations_1"."state" NOT IN ('pending', 'invited')
        SQL
      end
    end

    describe 'review queries' do
      let(:reviewer_report_types) do
        [TahiStandardTasks::ReviewerReportTask,
         TahiStandardTasks::FrontMatterReviewerReportTask,
         QueryParserSpec::FictionalReport
        ]
      end

      let(:reviewer_report_sql) { reviewer_report_types.map{ |r| "'#{r}'" }.join(', ') }

      it 'includes FictionalReport in the query (NOT) ALL REVIEWS COMPLETE query' do
        all_reviews_parse = QueryParser.new.parse 'ALL REVIEWS COMPLETE'
        not_all_reviews_parse = QueryParser.new.parse 'NOT ALL REVIEWS COMPLETE'

        expect(all_reviews_parse.to_sql).to include('QueryParserSpec::FictionalReport')
        expect(not_all_reviews_parse.to_sql).to include('QueryParserSpec::FictionalReport')
      end

      it 'parses ALL REVIEWS COMPLETE' do
        parse = QueryParser.new.parse 'ALL REVIEWS COMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."id" NOT IN (SELECT paper_id FROM "tasks" WHERE "tasks"."type" IN (#{reviewer_report_sql}) AND "tasks"."completed" = 'f') AND "tasks_0"."type" IN (#{reviewer_report_sql})
        SQL
      end

      it 'parses NOT ALL REVIEWS COMPLETE' do
        parse = QueryParser.new.parse 'NOT ALL REVIEWS COMPLETE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "tasks_0"."type" IN (#{reviewer_report_sql}) AND "tasks_0"."completed" = 'f'
        SQL
      end
    end

    describe 'people queries' do
      let!(:role) do
        create(:role, name: Faker::Name.title)
      end
      let!(:user) do
        create(:user, username: Faker::Lorem.word)
      end

      it 'parses USER username HAS ROLE x' do
        parse = QueryParser.new.parse "USER #{user.username} HAS ROLE #{role.name}"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."role_id" IN (#{role.id}) AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses USER me HAS ROLE x' do
        parse = QueryParser.new(current_user: user).parse "USER me HAS ROLE #{role.name}"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."role_id" IN (#{role.id}) AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses across multiple roles of same name for USER username HAS ROLE x' do
        role2 = create(:role, name: role.name)
        parse = QueryParser.new.parse "USER #{user.username} HAS ROLE #{role.name}"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."role_id" IN (#{role.id}, #{role2.id}) AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses USER username HAS ANY ROLE' do
        parse = QueryParser.new.parse "USER #{user.username} HAS ANY ROLE"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses USER me HAS ANY ROLE' do
        parse = QueryParser.new(current_user: user).parse 'USER me HAS ANY ROLE'
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses ANYONE HAS ROLE x' do
        parse = QueryParser.new.parse "ANYONE HAS ROLE #{role.name}"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."role_id" IN (#{role.id}) AND "assignments_0"."assigned_to_type" = 'Paper'
        SQL
      end

      it 'parses NO ONE HAS ROLE x' do
        parse = QueryParser.new.parse "NO ONE HAS ROLE #{role.name}"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "papers"."id" NOT IN (SELECT assigned_to_id FROM "assignments" WHERE "assignments"."role_id" IN (#{role.id}) AND "assignments"."assigned_to_type" = 'Paper')
        SQL
      end

      it 'parses USER username HAS ROLE x AND NO ONE HAS ROLE y' do
        role2 = create(:role, name: Faker::Name.title)
        parse = QueryParser.new.parse "USER #{user.username} HAS ROLE #{role2.name} AND NO ONE HAS ROLE #{role.name}"
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."role_id" IN (#{role2.id}) AND "assignments_0"."assigned_to_type" = 'Paper' AND "papers"."id" NOT IN (SELECT assigned_to_id FROM "assignments" WHERE "assignments"."role_id" IN (#{role.id}) AND "assignments"."assigned_to_type" = 'Paper')
        SQL
      end

      it 'parses USER username HAS ROLE x AND NO ONE HAS ROLE y with extra whitespace' do
        role2 = create(:role, name: Faker::Name.title)
        parse = QueryParser.new.parse "\tUSER #{user.username} HAS   \n  ROLE   #{role2.name}   AND NO \rONE\t HAS ROLE  #{role.name}  "
        expect(parse.to_sql).to eq(<<-SQL.strip)
          "assignments_0"."user_id" = #{user.id} AND "assignments_0"."role_id" IN (#{role2.id}) AND "assignments_0"."assigned_to_type" = 'Paper' AND "papers"."id" NOT IN (SELECT assigned_to_id FROM "assignments" WHERE "assignments"."role_id" IN (#{role.id}) AND "assignments"."assigned_to_type" = 'Paper')
        SQL
      end
    end

    context 'Date Queries' do
      describe 'task date queries' do
        it_behaves_like "a query parser date query",
          query: "TASK anytask HAS BEEN COMPLETED",
          sql: '"tasks_0"."title" ILIKE \'anytask\' AND "tasks_0"."completed_at"'
      end

      describe 'VERSION DATE queries' do
        it_behaves_like "a query parser date query",
          query: "VERSION DATE",
          sql: '"papers"."submitted_at"'
      end

      describe 'SUBMISSION DATE queries' do
        it_behaves_like "a query parser date query",
          query: "SUBMISSION DATE",
          sql: '"papers"."first_submitted_at"'
      end
    end
  end
end
