#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Title and Abstract Card
"""

from selenium.webdriver.common.by import By

from Base.PostgreSQL import PgSQL
from frontend.Cards.basecard import BaseCard

__author__ = 'jgray@plos.org'


class TitleAbstractCard(BaseCard):
  """
  Page Object Model for the Title and Abstract Card
  """
  def __init__(self, driver):
    super(TitleAbstractCard, self).__init__(driver)

    # Locators - Instance members
    self._title_label = (By.CSS_SELECTOR, 'div.qa-paper-title > h3')
    self._abstract_label = (By. CSS_SELECTOR, 'div.qa-paper-abstract > h3')

  # POM Actions
  def validate_styles(self):
    """
    Validate styles in the Title and Abstract Card
    :return: void function
    """
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Title And Abstract'
    self.validate_overlay_card_title_style(card_title)
    title_label = self._get(self._title_label)
    assert title_label.text == 'Title', title_label.text
    # self.validate_application_h3_style(title_label)
    self.get_rich_text_editor_instance('article-title-input')
    abstract_label = self._get(self._abstract_label)
    assert abstract_label.text == 'Abstract', abstract_label.text
    # self.validate_application_h3_style(abstract_label)
    self.get_rich_text_editor_instance('article-abstract-input')

  def check_title_abstract_card_population(self, short_doi):
    """
    Verify that the values populated in the form are those we have in the db
    :param short_doi: The paper.short_doi of the relevant manuscript
    :return: void function
    """
    db_title, db_abstract = PgSQL().query('SELECT title, abstract '
                                          'FROM papers '
                                          'WHERE short_doi=%s;', (short_doi,))[0]
    db_title = self.strip_tinymce_ptags(db_title)
    if db_abstract:
      db_abstract = self.strip_tinymce_ptags(db_abstract)
    tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
        self.get_rich_text_editor_instance('article-title-input')
    title = self.tmce_get_rich_text(tinymce_editor_instance_iframe)
    assert db_title == title, 'Title from page: {0} doesn\'t match title ' \
                              'from db: {1}'.format(title, db_title)
    tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
        self.get_rich_text_editor_instance('article-abstract-input')
    abstract = self.tmce_get_rich_text(tinymce_editor_instance_iframe)
    if db_abstract:
      assert db_abstract == abstract, 'Abstract from page: {0} doesn\'t match abstract ' \
                                      'from db: {1}'.format(abstract, db_abstract)

  def set_title(self, short_doi, title=''):
    """
    Set the title and then check value in db
    :param short_doi: The paper.short_doi of the relevant manuscript
    :param title: string, optional, title to set. Default title is 'Title inserted by Task' if not
      provided.
    :return: void function
    """
    if not title:
      title = 'Title inserted by Task'
    tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
        self.get_rich_text_editor_instance('article-title-input')
    self.tmce_clear_rich_text(tinymce_editor_instance_iframe)
    title = self.tmce_set_rich_text(tinymce_editor_instance_iframe, title)
    db_title = PgSQL().query('SELECT title '
                             'FROM papers '
                             'WHERE short_doi=%s;', (short_doi,))[0]
    db_title = self.strip_tinymce_ptags(db_title)
    assert db_title == title, 'Title from page: {0} doesn\'t match title ' \
                              'from db: {1}'.format(title, db_title)

  def set_abstract(self, short_doi, abstract=''):
    """
    Set the abstract and then check value in db
    :param short_doi: The paper.short_doi of the relevant manuscript
    :param abstract: string, optional, abstract to set. Default abstract is 'Abstract inserted by
      Task' if not provided.
    :return: void function
    """
    if not abstract:
      abstract = 'Abstract inserted by Task'
    tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
        self.get_rich_text_editor_instance('article-abstract-input')
    self.tmce_clear_rich_text(tinymce_editor_instance_iframe)
    abstract = self.tmce_set_rich_text(tinymce_editor_instance_iframe, abstract)
    db_abstract = PgSQL().query('SELECT abstract '
                                'FROM papers '
                                'WHERE short_doi=%s;', (short_doi,))[0][0]
    if db_abstract:
      db_abstract = self.strip_tinymce_ptags(db_abstract)
    # APERTA-10711 - until this is merged down to master this will not work
    # assert db_abstract == abstract, 'Abstract from page: {0} doesn\'t match abstract ' \
    #                                 'from db: {1}'.format(abstract, db_abstract)
