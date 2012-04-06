Feature: Sync task from one session to another
  In order to keep the list of tasks in sync accross users
  As a user updating a task
  I want the task shown to another user being updated accordingly

  @javascript
  Scenario: Viewing a task edited by another user
    Given the following users exist:
    | email |
    | alice@example.com |
    | olivia@example.com |
    Given the following task exists:
    | title |
    | Purchase Cheeseburgers |
    And I am using session "Alice"
    And I sign in as "alice@example.com"
    Then I should see "Purchase Cheeseburgers"
    When I switch to session "Olivia"
    And I sign in as "olivia@example.com"
    And I edit the "Purchase Cheeseburgers" task and rename it to "Purchase Giant Cheeseburgers"
    And I switch to session "Alice"
    Then I should see "Purchase Giant Cheeseburgers"