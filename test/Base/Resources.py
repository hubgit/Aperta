#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This Resource File sets variables that are used in individual
test cases. It eventually should be replaced with more robust,
less static, variable definitions.
"""

from os import getenv

# General resources
# set friendly_testhostname to 'prod' to run suite against production
# Two fields need to be changed to support running tests in your local development
# environment, first, set friendly_testhostname to localhost, then correct the
# base_url value if you are using a port or key different than 8081 and plosmatch.
'''
friendly_testhostname = 'tahitest'
friendly_testhostname = 'heroku'
if friendly_testhostname == 'prod':
  base_url = ''
elif friendly_testhostname == 'localhost':
  base_url = 'http://localhost:8081/'
else:
  base_url = 'localhost:5000/'
'''

friendly_testhostname = 'https://plos:shrimp@tahi-assess.herokuapp.com/'


# Aperta native registration resources
user_email = 'admin'
user_pw = 'yetishrimp'

user_data = {'admin': {'email': 'shrimp@mailinator.com',
                       'full_name': 'AD Shrimp',
                       'password': 'yetishrimp'}
             }

login_valid_email = 'sealresq+7@gmail.com'
login_invalid_email = 'jgrey@plos.org'
login_valid_uid = 'jgray_sa'
login_invalid_pw = 'in|fury7'
login_valid_pw = 'in|fury8'

au_login = {'user': 'jgray_author',
            'name': ''}
co_login = {'user': 'jgray_collab',
            'name': 'Jeffrey Collaborator',
            'password': login_invalid_pw}  # collaborator login
rv_login = {'user': 'jgray_reviewer',
            'name': 'Jeffrey RV Gray'}  # reviewer login
ae_login = {'user': 'jgray_assocedit'}  # associate editor login mm permissions
he_login = {'user': 'jgray_editor',
            'name': 'Jeffrey AMM Gray',
            'email': 'sealresq+4@gmail.com'}  # handling editor login amm permissions
fm_login = {'user': 'jgray_flowmgr'}   # flow manager permissions
oa_login = {'user': 'jgray_oa'}        # ordinary admin login
sa_login = {'user': 'jgray_sa'}        # super admin login

# Accounts for new permissions scheme
# These are NED CAS logins.
creator_login1 = {'user': 'aauthor1', 'name': 'atest author1', 'email': 'sealresq+1000@gmail.com'}
creator_login2 = {'user': 'aauthor2', 'name': 'atest author2', 'email': 'sealresq+1001@gmail.com'}
creator_login3 = {'user': 'aauthor3', 'name': 'atest author3', 'email': 'sealresq+1002@gmail.com'}
creator_login4 = {'user': 'aauthor4', 'name': 'atest author4', 'email': 'sealresq+1003@gmail.com'}
creator_login5 = {'user': 'aauthor5', 'name': 'atest author5', 'email': 'sealresq+1004@gmail.com'}
creator_login6 = {'user': 'aauthor6', 'name': 'atest author6', 'email': 'sealresq+1014@gmail.com'}
creator_login7 = {'user': 'aauthor7', 'name': 'atest author7', 'email': 'sealresq+1015@gmail.com'}
creator_login8 = {'user': 'aauthor8', 'name': 'atest author8', 'email': 'sealresq+1016@gmail.com'}
creator_login9 = {'user': 'aauthor9', 'name': 'atest author9', 'email': 'sealresq+1017@gmail.com'}
creator_login10 = {'user': u'hgrœnßmøñé',
                   'name': u'Hęrmänn. Grœnßmøñé',
                   'email': 'sealresq+1018@gmail.com'}
creator_login11 = {'user': 'aauthor11',
                   'name': 'atest author11',
                   'email': 'sealresq+1019@gmail.com'}
creator_login12 = {'user': u'æöxfjørd', 'name': u'Ænid Öxfjørd', 'email': 'sealresq+1020@gmail.com'}
creator_login13 = {'user': 'aauthor13',
                   'name': 'atest author13',
                   'email': 'sealresq+1021@gmail.com'}
creator_login14 = {'user': 'aauthor14',
                   'name': 'atest author14',
                   'email': 'sealresq+1022@gmail.com'}
creator_login15 = {'user': 'aauthor15',
                   'name': 'atest author15',
                   'email': 'sealresq+1023@gmail.com'}
creator_login16 = {'user': 'aauthor16',
                   'name': 'atest author16',
                   'email': 'sealresq+1024@gmail.com'}
creator_login17 = {'user': 'aauthor17',
                   'name': 'atest author17',
                   'email': 'sealresq+1025@gmail.com'}
creator_login18 = {'user': 'aauthor18',
                   'name': 'atest author18',
                   'email': 'sealresq+1026@gmail.com'}
creator_login19 = {'user': 'aauthor19',
                   'name': 'atest author19',
                   'email': 'sealresq+1027@gmail.com'}
creator_login20 = {'user': 'aauthor20',
                   'name': 'atest author20',
                   'email': 'sealresq+1028@gmail.com'}
creator_login21 = {'user': 'aauthor21',
                   'name': 'atest author21',
                   'email': 'sealresq+1029@gmail.com'}
creator_login22 = {'user': 'aauthor22',
                   'name': 'atest author22',
                   'email': 'sealresq+1030@gmail.com'}
creator_login23 = {'user': u'민성', 'name': u'민준 성', 'email': 'sealresq+1031@gmail.com'}
creator_login24 = {'user': u'志張', 'name': u'志明 張', 'email': 'sealresq+1032@gmail.com'}
creator_login25 = {'user': u'文孙', 'name': u'文 孙', 'email': 'sealresq+1033@gmail.com'}

reviewer_login = {'user': 'areviewer',
                  'name': 'atest reviewer',
                  'email': 'sealresq+1005@gmail.com'}
staff_admin_login = {'user': 'astaffadmin',
                     'name': 'atest staffadmin',
                     'email': 'sealresq+1006@gmail.com'}
handling_editor_login = {'user': 'ahandedit',
                         'name': 'atest handedit',
                         'email': 'sealresq+1007@gmail.com'}
pub_svcs_login = {'user': 'apubsvcs',
                  'name': 'atest pubsvcs',
                  'email': 'sealresq+1008@gmail.com'}
academic_editor_login = {'user': 'aacadedit',
                         'name': 'atest acadedit',
                         'email': 'sealresq+1009@gmail.com'}
internal_editor_login = {'user': 'aintedit',
                         'name': 'atest intedit',
                         'email': 'sealresq+1010@gmail.com'}
super_admin_login = {'user': 'asuperadm',
                     'name': 'atest superadm',
                     'email': 'sealresq+1011@gmail.com'}
cover_editor_login = {'user': 'acoveredit',
                      'name': 'atest coveredit',
                      'email': 'sealresq+1012@gmail.com'}
prod_staff_login = {'user': 'aprodstaff',
                    'name': 'atest prodstaff',
                    'email': 'sealresq+1013@gmail.com'}
# anyone can be a discussion_participant
# everyone has a user role for their own profile page

users = [creator_login1,
         creator_login2,
         creator_login3,
         creator_login4,
         creator_login5,
         creator_login6,
         creator_login7,
         creator_login8,
         creator_login9,
         creator_login10,
         creator_login11,
         creator_login12,
         creator_login13,
         creator_login14,
         creator_login15,
         creator_login16,
         creator_login17,
         creator_login18,
         creator_login19,
         creator_login20,
         creator_login21,
         creator_login22,
         creator_login23,
         creator_login24,
         creator_login25,
         ]

editorial_users = [internal_editor_login,
                   staff_admin_login,
                   super_admin_login,
                   prod_staff_login,
                   pub_svcs_login,
                   ]

external_editorial_users = [cover_editor_login,
                            handling_editor_login,
                            academic_editor_login,
                            ]

# Define connector information for Aperta's Tahi component postgres instance
# NOTA BENE: Production data should NEVER be included in this file.
# Staging data (Heroku CI)
psql_hname = getenv('APERTA_PSQL_HOST', 'ec2-54-83-5-30.compute-1.amazonaws.com')
psql_port = getenv('APERTA_PSQL_PORT', '6262')
psql_uname = getenv('APERTA_PSQL_USER', 'u2kgbfse1i57n')
psql_pw = getenv('APERTA_PSQL_PW', '')
psql_db = getenv('APERTA_PSQL_DBNAME', 'dd2kjrv61vaj33')
# Release Candidate data (SFO)
# psql_hname = getenv('APERTA_PSQL_HOST', 'db-aperta-201.sfo.plos.org')
# psql_port = getenv('APERTA_PSQL_PORT', '5432')
# psql_uname = getenv('APERTA_PSQL_USER', 'tahi')
# psql_pw = getenv('APERTA_PSQL_PW', '')
# psql_db = getenv('APERTA_PSQL_DBNAME', 'tahi')

editor_name_0 = 'Hendrik W. van Veen'
user_email_0 = 'trash87567@ariessc.com'
editor_name_1 = 'Anthony George'
user_email_1 = 'trash261121@ariessc.com'
user_pw_editor = 'test_password'

# Fake affiliations
affiliation = {'institution': 'Universidad Del Este',
               'title': 'Dr.',
               'country': 'Argentina',
               'start': '12/01/2014',
               'end': '08/11/2015',
               'email': 'test@test.org',
               'department': 'Molecular Biology',
               'initials': 'JMD',
               'government': False,}

# Author for Author card
author = {'first': 'Jane',
          'middle': 'M',
          'last': 'Doe',
          'initials': 'JMD',
          'title': 'Dr.',
          'email': 'test@test.org',
          'department': 'Molecular Biology',
          '1_institution': 'Universidad Del Este',
          '2_institution': 'Universidad Nacional del Sur'}

group_author = {'group_name': 'Rebel Alliance',
                'group_inits': 'RA',
                'first': 'Jackson',
                'middle': 'V',
                'last': 'Stoeffer',
                'email': 'test@test.org'}

billing_data = {'first': 'Jane',
                'last': 'Doe',
                'title': 'Dr.',
                'email': 'test@test.org',
                'department': 'Molecular Biology',
                'affiliation': 'Universidad Del Este',
                '2_institution': 'Universidad Nacional del Sur',
                'address1': 'Codoba 2231',
                'phone': '123-4567-8900',
                'city': 'Azul',
                'state': 'CABA',
                'ZIP': '12345',
                'country': 'Argentina'}

docs = ['10yearsRabiesSL20140723.doc',
        '11-OvCa-Collab-HeightBMI-paper-July.doc',
        '120220_PLoS_Genetics_review.docx',
        '2011_10_28_PLOS-final.doc',
        '2014_04_27_Bakowski_et_al_main_text_subm.docx',
        '20160211_WilsonJetz_Clouds.docx',
        '3. User Test4_MS File 2.docx',
        '3. User Test4_MS File 3.docx',
        '3. User Test4_MS File.docx',
        '3. User Testing3_MS File 2.docx',
        '3. User Testing3_MS File.docx',
        '3.User_Testing3_MS_File.docx',
        'Aedes_hensilli_vector_capacity-final-3-clean-plosntd.doc',
        'Alagapan_2015_Manuscript_Revised_FINAL.docx',
        'April_editorial_2012.doc',
        'Article_RJ FINAL.docx',
        'C6_Text_Final.doc',
        'CRX.pone.0103411.docx',
        'Carey_vanDijk__Final.doc',
        'Chemical Synthesis of Bacteriophage G4.doc',
        'EGFR_PLOS_GENETICS.docx',
        'Final version PLOS Biology SCAP manuscript.doc',
        'GIANT-gender-main_20130310.docx',
        'Hamilton_Yu_121611.doc',
        'Hobatier_et_al._final.docx',
        'Hotez-NTDs_2_0_shifting_policy_landscape_PLOS_NTDs_figs_extracted_for_submish.docx',
        'IPDms1_textV5.doc',
        'IPTc_Review_FINAL_v5_100111_clean.doc',
        'Institutional_Predictors-8-14_clean_copy_1_HB_MW.docx',
        'Jouffe et al clean copy -R5.docx',
        'Jouffe et al-R2.doc',
        'July_Blue_Marble_Editorial_final_for_accept_16June.docx',
        'LifeExpectancyART10_PM_RM_edits_FINAL.doc',
        'MCCOY_PLOS_Biology_resub.docx',
        'Manuscript_Monitoring_HIV_Viral_Load_in_Resource_Limited_PLoSONE-1_MA_28082012.docx',
        'Manuscript_resubmission_1 April2014_REVISED.docx',
        'Manuscript_revised_final.doc',
        'ModularModeling-PLoSCompBioPerspective_2ndREVISION.doc',
        'Moon_and_Wilusz-PLoS_Pearl_REVISED_Version_FINAL_9-25.docx',
        'Ms_clean.docx',
        'NF-kB-Paper_manuscript.docx',
        'NLP-PLoS4Unhighlighted.doc',
        'NMR_for_submission_7_Feb_2011.doc',
        'Nazzi_ms_def.doc',
        'NonMarked_Maxwell_PLoSBiol_060611.doc',
        'NorenzayanetalPLOS.docx',
        'PGENETICS-D-13-02065R1_FTC.docx',
        'PLOS A case for investing in Global Health_resubmission_vvfinal.docx',
        'PLOS_Comp_Bio_Second_Revision.docx',
        'PLP_D-14-00383R1-7.9.14.doc',
        'PLoS-ACUDep_Primary_Clinical_Results-version12-6August2013-final.docx',
        'PLoS_article.doc',
        'PLosOne_Main_Body_Ravi_Bansal_Brad_REVISED.docx',
        'PNTD-D-12-00578_Revised manuscript Final_(5.9.2012).doc',
        'PONE-D-12-25504.docx',
        'PONE-D-12-27950.docx',
        'PONE-D-12-30946.doc',
        'PONE-D-13-00751.doc',
        'PONE-D-13-02344.docx',
        'PONE-D-13-04452.doc',
        'PONE-D-13-11786.doc',
        'PONE-D-13-14162.docx',
        'PONE-D-13-19782.docx',
        'PONE-D-13-38666.docx',
        'PONE-D-14-12686.docx',
        'PONE-D-14-17217.docx',
        'PONE_manuscript v2 clean.docx',
        'PPATHOGENS-D-14-01213.docx',
        'Plos Biology Manuscript.Final-1.doc',
        'Pope_et_al._revised_11-12-10.docx',
        'RTN.pone.0072333.docx',
        'RTN.pone.0072333_edited.docx',
        'Revised Kelly et al MS PBIOLOGY-D-1201861R1-1_13-02-28.docx',
        'Revisedmanuscript11_1.doc',
        'Rohde_PLoS_Pathogens.doc',
        'Schallmo_PLOS_RevisedManuscript.docx',
        'Schallmo_PLOS_RevisedManuscript_edited.docx',
        'Spindler_2014_rerevised.docx',
        'Stroke_review_resubmission4_LR.docx',
        'Text_Mouillot_et_al._Plos_Biology_Final3RJ.docx',
        'Text_Mouillot_et_al._Plos_Biology_Final3RJ_edited.docx',
        'Thammasri_PONE_D13_12078_wo.docx',
        'Thammasri_PONE_D13_12078_wo_edited.docx',
        'The+cost+of+noise+PDF+Submitted+Merged+5-11-16+v3.docx',
        'Trevor Mundel PLoS Biology 10-2-2015 FINAL.docx',
        'beta-diversity-PLOS+Biology.docx',
        'chiappini_et_al.doc',
        'equations.docx',
        'importeddoslinefeeds.docx',
        'importedunixlinefeeds.docx',
        'iom_essay02.doc',
        'manuscript.doc',
        'manuscript_clean.doc',
        'pgen.1004127.docx',
        'pone.0100365.docx',
        'pone.0100948.docx',
        'ppat.1004210.docx',
        'revised_maintext_20160226_formatted_FINAL.docx',
        'resubmission_text_ethics_changed.doc',
        'sample.docx',
        'tbParBSASpl1.docx',
        'beta-diversity-PLOS+Biology.docx',
        'Forni_2CMF_PlosBiology_Final.+edited24.06.16.docx',
        'Gawryluk_PLoS_2016_Aperta_1.docx',
        'Nie+et+al.docx',
        'The_2Bcost_2Bof_2Bnoise_2BPDF_2BSubmitted_2BMerged_2B5-11-16_2Bv4.docx',
        'Ovine_Rumen_Metabolism_PLoSBio.docx',
        'Oya_et_al_Plosbio_manuscript_corrected.docx',
        'Raz_maintext.edit_Edited.docx',
        'manuscript.docx',
        'manuscript_w_embedded_charts.docx',
        'Manuscript_2106_edited_2.docx',
        'Li_et_al_2015_final.docx',
        'AdoMetDC_covalent_inhibitor_1.docx',
        'Banisch_Final.docx',
        'paper248_Kadison+Manuscript_June+2016-1_edited.docx',
        'Schelhaas_preclinical_FLT_review_Edited.docx',
        'Kurian_et_al_PLOS2016.docx'
        ]

figures = ['FIg1_2B_281_29.eps',
           'FIgure_1.tif',
           'Fig 1.tif',
           'Fig 2.tif',
           'Fig 3.tif',
           'Fig 4.tif',
           'Fig 5.tif',
           'Fig 6.tif',
           'Fig 7.tif',
           'Fig S1.tif',
           'Fig S10.tif',
           'Fig S11.tif',
           'Fig S12.tif',
           'Fig S13.1.tif',
           'Fig S14.tif',
           'Fig S15.tif',
           'Fig S16.tif',
           'Fig S17.tif',
           'Fig S18.tif',
           'Fig S2.tif',
           'Fig S3.tif',
           'Fig S4.tif',
           'Fig S5.tif',
           'Fig S6.tif',
           'Fig S7.tif',
           'Fig S8.tif',
           'Fig S9.tif',
           'Fig1 2.tif',
           'Fig1 3.tif',
           'Fig1 4.tif',
           'Fig1 5.tif',
           'Fig1 6.tif',
           'Fig1 7.tif',
           'Fig1.tif',
           'Fig2 2.tif',
           'Fig2 copy.tif',
           'Fig2.tif',
           'Fig2_2B_282_29.eps',
           'Fig3 2.tif',
           'Fig3.tif',
           'Fig3_2B_282_29.eps',
           'Fig4 2.tif',
           'Fig4 copy.tif',
           'Fig4.tif',
           'Fig5.tif',
           'Figure 1 PLoS.tif',
           'Figure 1.tiff',
           'Figure 1_updated.tif',
           'Figure 2 PLoS.tiff',
           'Figure 2.revised.tiff',
           'Figure 3 PLoS.tif',
           'Figure 3.tiff',
           'Figure 4.tiff',
           'Figure 5.tiff',
           'Figure S1.tiff',
           'Figure S2.tiff',
           'Figure S3.tiff',
           'Figure S4.tiff',
           'Figure S5.tiff',
           'Figure_2.tif',
           'Figure_3.tif',
           'Figure_4.tif',
           'Figure_5.tif',
           'Figure_6.tif',
           'Figure_7.tif',
           'Figure_S1.tif',
           'Figure_S2.tif',
           'Figure_S3.tif',
           'Figure_S4.tif',
           'HIV testing_journal.pmed.1001874.g003.tiff',
           'Kelly_Figure 10_23-02-13.tif',
           'Kelly_Figure 11_23-02-13.tif',
           'Kelly_Figure 12_23-02-13.tif',
           'Kelly_Figure 1_22-01-13.tif',
           'Kelly_Figure 2_22-02-13.tif',
           'Kelly_Figure 3_22-02-13.tif',
           'Kelly_Figure 4_22-02-13.tif',
           'Kelly_Figure 5_22-02-13.tif',
           'Kelly_Figure 6_22-02-13.tif',
           'Kelly_Figure 7_23-02-13.tif',
           'Kelly_Figure 8_23-02-132.tif',
           'Kelly_Figure 9_23-02-13.tif',
           'Kelly_Figure S1_23-02-13.tif',
           'Kelly_Figure S2_23-02-13.tif',
           'Kelly_Figure S3_23-02-13.tif',
           'Kelly_Figure S4_25-02-13.tif',
           'Kelly_Figure S5_23-02-13.tif',
           'Kelly_Figure S6_23-02-13.tif',
           'Kelly_Figure S7_23-02-13.tif',
           'Kelly_Figure S8_23-02-13.tif',
           'S2_Fig.tif',
           'S3_Fig.tif',
           'S5_Fig.tif',
           'S6_Fig.tif',
           'S7_Fig.tif',
           'S8_Fig.tif',
           'StrikingImage_Seasonality.tif',
           'Strikingimage.tiff',
           'ant foraging_journal.pcbi.1002670.g003.tiff',
           'ardea_herodias_lzw_sm.tiff',
           'ardea_herodias_lzw.tiff',
           'are_you_edible_packbits.tiff',
           'cameroon_journal.pntd.0004001.g009.tiff',
           'dengue virus_journal.ppat.1002631.g001.tiff',
           'fig1.eps',
           'fig2.eps',
           'fig3.eps',
           'fig4.eps',
           'fig5.eps',
           'fig6.eps',
           'figS1.eps',
           'figS10.eps',
           'figS11.eps',
           'figS2.eps',
           'figS3.eps',
           'figS4.eps',
           'figS5.eps',
           'figS6.eps',
           'figS7.eps',
           'figS8.tiff',
           'figS9.eps',
           'figure1_tiff_lzw.tiff',
           'figure1_tiff_nocompress.tiff',
           'figure1_tiff_packbits.tiff',
           'figure1eps.eps',
           'figure2_tiff_lzw.tiff',
           'figure2_tiff_nocompress.tiff',
           'figure2_tiff_packbits.tiff',
           'figure2eps.eps',
           'figure3_tiff_lzw.tiff',
           'figure3_tiff_nocompress.tiff',
           'figure3_tiff_packbits.tiff',
           'figure3eps.eps',
           'fur_elise_nocompress.tiff',
           'genetics_journal.pgen.1003059.g001.tiff',
           'ion selectivity_journal.pbio.1002238.g005.tiff',
           'jag_rtha_lzw.tiff',
           'jag_rtha_nocompress.tiff',
           'jag_rtha_packbits.tiff',
           'killer whale vocalisations_journal.pone.0136535.g001.tiff',
           'monkey brain_journal.pbio.1002245.g003.tiff',
           'monkey.eps',
           'monkey_lzw_compress.tiff',
           'monkey_nocompress.tiff',
           'monkey_packbits_compress.tiff',
           'p10x.tif',
           'p11x.tif',
           'p1x.tif',
           'p2x.tif',
           'p3x.tif',
           'p4x.tif',
           'p5x.tif',
           'p6x.tif',
           'p7x.tif',
           'p8x.tif',
           'p9x.tif',
           'production performance.tiff',
           'reggie-watts_15057274790_o.tif',
           'snakebite_journal.pntd.0002302.g001.tiff',
           'stripedshorecrab.eps',
           'wild rhinos_journal.pone.0136643.g001.tiff',
           ]

# Note that this usage of task names doesn't differentiate between presentations as tasks, in the
#   accordion, and as cards, on the workflow page. This label is being used generically here.
task_names = ['Ad-hoc',
              'Additional Information',
              'Assign Admin',
              'Assign Team',
              'Authors',
              'Billing',
              'Competing Interests',
              'Cover Letter',
              'Data Availability',
              'Editor Discussion',
              'Ethics Statement',
              'Figures',
              'Final Tech Check',
              'Financial Disclosure',
              'Front Matter Reviewer Report',
              'Initial Decision',
              'Initial Tech Check',
              'Invite Academic Editor',
              'Invite Reviewers',
              'New Taxon',
              'Production Metadata',
              'Register Decision',
              'Related Articles',
              'Reporting Guidelines',
              'Reviewer Candidates',
              'Revision Tech Check',
              'Send to Apex',
              'Supporting Info',
              'Title And Abstract',
              'Upload Manuscript']

yeti_task_names = ['Ad-hoc',
                   'Additional Information',
                   'Assign Admin',
                   'Assign Team',
                   'Authors',
                   'Billing',
                   'Competing Interests',
                   'Cover Letter',
                   'Data Availability',
                   'Editor Discussion',
                   'Ethics Statement',
                   'Figures',
                   'Final Tech Check',
                   'Financial Disclosure',
                   'Front Matter Reviewer Report',
                   'Initial Decision',
                   'Initial Tech Check',
                   'Invite Academic Editor',
                   'Invite Reviewers',
                   'New Taxon',
                   'Production Metadata',
                   'Register Decision',
                   'Related Articles',
                   'Reporting Guidelines',
                   'Reviewer Candidates',
                   'Revision Tech Check',
                   'Send to Apex',
                   'Supporting Info',
                   'Test Task',
                   'Title And Abstract',
                   'Upload Manuscript']

paper_tracker_search_queries = ['0000003',
                                'Genome',
                                'DOI IS pwom',
                                'TYPE IS research',
                                'DECISION IS major revision',
                                'STATUS IS submitted',
                                'TITLE IS genome',
                                'STATUS IS rejected OR STATUS IS withdrawn',
                                'TYPE IS research AND (STATUS IS rejected OR STATUS IS withdrawn)',
                                'STATUS IS NOT unsubmitted',
                                'USER aacadedit HAS ROLE academic editor',
                                'USER ahandedit HAS ANY ROLE',
                                'ANYONE HAS ROLE cover editor',
                                'USER aacadedit HAS ROLE academic editor AND STATUS IS submitted',
                                'USER astaffadmin HAS ROLE staff admin AND NO ONE HAS ROLE '
                                'academic editor',
                                'NO ONE HAS ROLE staff admin',
                                'SUBMITTED > 3 DAYS AGO',
                                'SUBMITTED < 1 DAY AGO',
                                'USER me HAS ANY ROLE',
                                'TASK invite reviewers HAS OPEN INVITATIONS',
                                'TASK invite academic editors HAS OPEN INVITATIONS',
                                'ALL REVIEWS COMPLETE',
                                'NOT ALL REVIEWS COMPLETE'
                                ]
