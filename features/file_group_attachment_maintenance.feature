Feature: File group attachment maintenance
  In order to organize documents created outside of the system
  As a librarian
  I want to maintain files attached to file groups

  Background:
    Given I am logged in as an admin
    And the collection with title 'Animals' has child file groups with fields:
      | title |
      | Dogs |
    And I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Add Attachment'
    And I fill in fields:
      | Description | What the attachment is. |
    And I attach fixture file 'grass.jpg' to 'Attachment'
    And I click on 'Create'

  Scenario: Download attachment from file group
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Download'
    Then I should be on the download page for the attachment 'grass.jpg'

  Scenario: Download attachment from file group as a manager
    Given I relogin as a manager
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Download'
    Then I should be on the download page for the attachment 'grass.jpg'

  Scenario: Download attachment from file group as a user
    Given I relogin as a user
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Download'
    Then I should be on the download page for the attachment 'grass.jpg'

  Scenario: Delete attachment from file group
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Delete' in the attachments section
    Then I should be on the view page for the file group with title 'Dogs'
    And the file group with title 'Dogs' should have 0 attachments

  Scenario: Update attachment from file group
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Edit' in the attachments section
    And I fill in fields:
      | Description | New info for attachment |
    And I attach fixture file 'fits.xml' to 'Attachment'
    And I click on 'Update'
    And I click on 'Attachments'
    Then I should see 'New info for attachment'
    And I should not see 'What the attachment is.'
    And the file group with title 'Dogs' should have 1 attachment

  Scenario: Update attachment from file group as a manager
    Given I relogin as a manager
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Edit' in the attachments section
    And I fill in fields:
      | Description | New info for attachment |
    And I attach fixture file 'fits.xml' to 'Attachment'
    And I click on 'Update'
    And I click on 'Attachments'
    Then I should see 'New info for attachment'
    And I should not see 'What the attachment is.'
    And the file group with title 'Dogs' should have 1 attachment

  Scenario: View attachment details
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'grass.jpg'
    Then I should see all of:
      | grass.jpg | What the attachment is. | image/jpeg |

  Scenario: View attachment details as manager
    Given I relogin as a manager
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'grass.jpg'
    Then I should see all of:
      | grass.jpg | What the attachment is. | image/jpeg |

  Scenario: View attachment details as a user
    Given I relogin as a user
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'grass.jpg'
    Then I should see all of:
      | grass.jpg | What the attachment is. | image/jpeg |

