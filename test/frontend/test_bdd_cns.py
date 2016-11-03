#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import time

from Base.Decorators import MultiBrowserFixture
from Base.Resources import login_valid_pw, users

from frontend.common_test import CommonTest
from Pages.dashboard import DashboardPage
from Pages.manuscript_viewer import ManuscriptViewerPage

"""
This behavioral test case validates the Aperta Create New Submission through Submit process.
"""
__author__ = 'jgray@plos.org'

cards = ['cover_letter',
         'billing',
         'figures',
         'authors',
         'supporting_info',
         'upload_manuscript',
         'addl_info_task',
         'review_candidates',
         'revise_task',
         'competing_interests',
         'data_availability',
         'ethics_statement',
         'financial_disclosure',
         'new_taxon',
         'reporting_guidelines',
         'changes_for_author',
         ]


@MultiBrowserFixture
class ApertaBDDCNStoSubmitTest(CommonTest):
  """
  Self imposed AC:
    log in as author
    Aperta takes you to Dashboard
    click “create new submission”
    enter a title
    select the journal that you are submitting to
    choose the journal PLOS Wombat
    choose the type of paper (Research)
    drag manuscript/attach to “upload manuscript” or click “upload manuscript” to upload manuscript
    end up on the manuscript page
    begin working through the cards on the right-hand side (don’t have to go in order that they are
      displayed)
    general
    after you complete each card, check “complete” and “close” to return to manuscript page
    for a few cards, try to:
    check complete and close and then reopen to make sure that the comments saved
    don’t check complete, close and then reopen to see if the comments saved (everything should
        save)
    billing
    enter payee details
    select how you would like to pay
    cover letter
    paste in cover letter
    upload manuscript
    should be complete already (gray) but if not, upload the manuscript here
    figures
    check “yes, I confirm…”
    add new figures
    once figure is uploaded, enter figure captions\
    click “save”
    upload 1-2 figures
    one tiff and one eps
    ethics statement
    answer questions 1 and 2 and provide explanations when prompted
    reviewer candidates
    enter reviewer details for 2 reviewers (either recommend or oppose)
    enter a reviewer who doesn’t have an account in Aperta
    enter a reviewer who does have an account in Aperta
    confirm that the editor receives the reviewer recommendation card as it was completed by the
        submitting author
    reporting guidelines
    check Systematic Review or Meta-Analysis
    select and upload word doc
    supporting info
    “add new supporting information”
    add a title
    add a caption
    try uploading a docx, an excel file, pdf, ppt and any image file
    financial disclosures
    answer question “yes” and add 2 funders
    enter funder information
    indicate that one of them has a role in study design and input descriptoin
    be sure to confirm that the funder name appears appropriately in the published financial
        disclosure statement that is indicated at the bottom
    confirm that once a website is added to the funder information, a hyperlink is automatically
        created (associated to funder name below)
    authors
    add a corresponding author
    add one additional authors
    should be able to search an institution/affiliations
    publishing related questions
    select “yes” for at least one of the questions and provide the necessary information
    check to see if you are able to complete the card without providing certain information
    data availability
    doesn’t matter if you select “yes” or “no”
    competing interests
    answer yes, provide statement
    once you’ve completed all cards, check to make sure that all cards appear gray
    Hit SUBMIT and confirm

  """
  def test_validate_create_to_submit(self, init=True):
    """
    test_bdd_cns: Validates Creating a new document - needs extension to take it through to Submit
    Validates the presence of the following elements:
      Optional Invitation Welcome text and button,
      My Submissions Welcome Text, button, info text and manuscript display
      Modals: View Invites and Create New Submission
    """
    logging.info('Test BDDCNStoSubmitTest::validate_create_to_submit')
    current_path = os.getcwd()
    logging.info(current_path)
    user_type = random.choice(users)
    dashboard_page = self.cas_login(email=user_type['email']) if init \
        else DashboardPage(self.getDriver())
    dashboard_page.click_create_new_submission_button()
    # Temporary changing timeout
    dashboard_page.set_timeout(60)
    # We recently became slow drawing this overlay (20151006)
    time.sleep(.5)
    self.create_article(journal='PLOS Wombat',
                        type_='Research',
                        random_bit=True,
                        title='bdd_cns',
                        )
    dashboard_page.restore_timeout()
    # Time needed for iHat conversion. This is not quite enough time in all circumstances
    time.sleep(7)
    manuscript_page = ManuscriptViewerPage(self.getDriver())
    manuscript_page.validate_ihat_conversions_success(fail_on_missing=True)
    # Outputting the title allows us to validate update following conversion
    db_id = manuscript_page.get_paper_id_from_url()
    logging.info('Paper database id is: {0}'.format(db_id))
    title = manuscript_page.get_paper_title_from_page()
    logging.info('Paper page title is: {0}'.format(title))

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
