#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import time
from selenium.webdriver.common.by import By

from Base.Resources import figures
from frontend.Tasks.basetask import BaseTask

__author__ = 'jgray@plos.org'

class FiguresTask(BaseTask):
  """
  Page Object Model for Figures task
  """

  def __init__(self, driver, url_suffix='/'):
    super(FiguresTask, self).__init__(driver)

    #Locators - Instance members
    self._intro_text = (By.CSS_SELECTOR, 'div.task-main-content p')
    self._question_label = (By.CLASS_NAME, 'question-checkbox')
    self._question_check = (By.CLASS_NAME, 'ember-checkbox')
    self._add_new_figures_btn = (By.CLASS_NAME, 'button-primary')

  # POM Actions
  def validate_styles(self):
    """
    Validate styles in Figures Task
    """
    intro_text = self._get(self._intro_text)
    # The intro paragraph is rendered in the incorrect font size
    # self.validate_application_ptext(intro_text)
    assert intro_text.text == (
        "Please confirm that your figures comply with our guidelines for preparation and "
        "have not been inappropriately manipulated. For information on image manipulation, "
        "please see our general guidance notes on image manipulation."
        ), intro_text.text
    assert self._get(self._question_label).text == 'Yes - I confirm our figures comply with the ' \
                                                   'guidelines.'
    self.validate_application_ptext(self._get(self._question_label))
    add_new_figures_btn = self._get(self._add_new_figures_btn)
    assert add_new_figures_btn.text == "ADD NEW FIGURES"
    self.validate_primary_big_green_button_style(add_new_figures_btn)

  def check_question(self):
    """
    Click on the checkbox for the question:
    "Yes - I confirm our figures comply with the guidelines."
    :return: None
    """
    writable = not self.completed_state()
    if writable:
      self._get(self._question_check).click()
    else:
      self.click_completion_button()
      self._get(self._question_check).click()
      self.click_completion_button()

  def is_question_checked(self):
    """
    Checks if checkmark for the question on Figures task is applied or not
    :return: Bool
    """
    question_check= self._get(self._question_check)
    if question_check.is_selected():
      return True
    else:
      return False

  def upload_figure(self, figure='random'):
    """
    Function to upload a figure file
    :param figure: Name of the figure to upload. If blank will default to 'random', this will choose
      one of available figures
    :return filename of uploaded figure
    """
    if figure == 'random':
      figure = random.choice(figures)
      fn = os.path.join(os.getcwd(), 'frontend/assets/imgs/{0}'.format(figure))
    else:
      fn = os.path.join(os.getcwd(), 'frontend/assets/imgs/', figure)
    logging.info('Sending figure: {0}'.format(fn))
    time.sleep(1)
    self._driver.find_element_by_id('figure_attachment').send_keys(fn)
    add_new_figures_btn = self._get(self._add_new_figures_btn)
    add_new_figures_btn.click()
    # Time needed for script execution.
    time.sleep(7)
    return figure
