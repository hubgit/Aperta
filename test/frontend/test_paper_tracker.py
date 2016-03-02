#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This test case validates the Aperta paper_tracker page.

Note that this case does NOT test actually creating a new manuscript, or accepting or declining an invitation
Those acts are expected to be defined in

"""
__author__ = 'jgray@plos.org'

import random

from Base.Decorators import MultiBrowserFixture
from Pages.login_page import LoginPage
from Pages.dashboard import DashboardPage
from Pages.paper_tracker import PaperTrackerPage
from Base.Resources import login_valid_pw, staff_admin_login, internal_editor_login, pub_svcs_login, super_admin_login
from frontend.common_test import CommonTest

users = [staff_admin_login,
         internal_editor_login,
         pub_svcs_login,
         super_admin_login,
         ]

@MultiBrowserFixture
class ApertaPaperTrackerTest(CommonTest):
  """
  Self imposed AC:
     - validate page elements and styles for:
      - welcome message
      - subhead with paper total presentation
      - presentation of the table
      - presentation of individual data points for each paper
  """
  def test_validate_paper_tracker(self):
    """
    Validates the presence of the following elements:
      Welcome Text, subhead, table presentation
    """
    user_type = random.choice(users)
    print('Logging in as user: {}'.format(user_type['user']))
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(user_type['email'])
    login_page.enter_password_field(login_valid_pw)
    login_page.click_sign_in_button()

    dashboard_page = DashboardPage(self.getDriver())
    dashboard_page.click_paper_tracker_link()

    pt_page = PaperTrackerPage(self.getDriver())
    (total_count, journals_list) = pt_page.validate_heading_and_subhead(user_type['user'])
    pt_page.validate_table_presentation_and_function(total_count, journals_list)
    pt_page.validate_nav_toolbar_elements(user_type['user'])

if __name__ == '__main__':
  CommonTest._run_tests_randomly()
