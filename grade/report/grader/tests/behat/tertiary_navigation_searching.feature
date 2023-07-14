@core @javascript @gradereport @gradereport_grader
Feature: Within the grader report, test that we can search for users
  In order to find specific users in the course gradebook
  As a teacher
  I need to be able to see the search input and trigger the search somehow

  Background:
    Given the following "courses" exist:
      | fullname | shortname | category | groupmode |
      | Course 1 | C1        | 0        | 1         |
    And the following "users" exist:
      | username | firstname | lastname | email                | idnumber | phone1     | phone2     | department | institution | city    | country  |
      | teacher1 | Teacher   | 1        | teacher1@example.com | t1       | 1234567892 | 1234567893 | ABC1       | ABCD        | Perth   | AU       |
      | student1 | Student   | 1        | student1@example.com | s1       | 3213078612 | 8974325612 | ABC1       | ABCD        | Hanoi   | VN       |
      | student2 | Dummy     | User     | student2@example.com | s2       | 4365899871 | 7654789012 | ABC2       | ABCD        | Tokyo   | JP       |
      | student3 | User      | Example  | student3@example.com | s3       | 3243249087 | 0875421745 | ABC2       | ABCD        | Olney   | GB       |
      | student4 | User      | Test     | student4@example.com | s4       | 0987532523 | 2149871323 | ABC3       | ABCD        | Tokyo   | JP       |
      | student5 | Turtle    | Manatee  | student5@example.com | s5       | 1239087780 | 9873623589 | ABC3       | ABCD        | Perth   | AU       |
    # Note: Add groups etc so we can test that the search ignores those filters as well if we go down the filter dataset path.
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
      | student1 | C1     | student        |
      | student2 | C1     | student        |
      | student3 | C1     | student        |
      | student4 | C1     | student        |
      | student5 | C1     | student        |
    And the following "activities" exist:
      | activity | course | idnumber | name                |
      | assign   | C1     | a1       | Test assignment one |
    And the following config values are set as admin:
      | showuseridentity | idnumber,email,city,country,phone1,phone2,department,institution |
    And I am on the "Course 1" "Course" page logged in as "teacher1"
    And I change window size to "large"
    And I navigate to "View > Grader report" in the course gradebook

  Scenario: A teacher can view and trigger the user search
    # Check the placeholder text
    Given I should see "Search users"
    # Confirm the search is currently inactive and results are unfiltered.
    And the following should exist in the "user-grades" table:
      | -1-                |
      | Turtle Manatee     |
      | Student 1          |
      | User Example       |
      | User Test          |
      | Dummy User         |
    And the following should not exist in the "user-grades" table:
      | -1-                |
      | Teacher 1          |
    When I set the field "Search users" to "Turtle"
    And I wait until "View all results (1)" "option_role" exists
    And "Turtle Manatee" "list_item" should exist in the ".user-search" "css_element"
    And "User Example" "list_item" should not exist in the ".user-search" "css_element"
    And I click on "Turtle Manatee" "list_item"
    # Business case: This will trigger a page reload and can not dynamically update the table.
    And I wait until the page is ready
    Then the following should exist in the "user-grades" table:
      | -1-                |
      | Turtle Manatee     |
    And the following should not exist in the "user-grades" table:
      | -1-                |
      | Teacher 1          |
      | Student 1          |
      | User Example       |
      | User Test          |
      | Dummy User         |
    And I set the field "Search users" to "Turt"
    And I wait until "View all results (1)" "option_role" exists
    And I click on "Clear search input" "button" in the ".user-search" "css_element"
    And "View all results (1)" "option_role" should not be visible

  Scenario: A teacher can search the grader report to find specified users
    # Case: Standard search.
    Given I set the field "Search users" to "Dummy"
    And I wait until "View all results (1)" "option_role" exists
    And I click on "Dummy User" "option_role"
    And I wait until the page is ready
    And the following should exist in the "user-grades" table:
      | -1-                |
      | Turtle Manatee     |
    And the following should not exist in the "user-grades" table:
      | -1-                |
      | Teacher 1          |
      | Student 1          |
      | User Example       |
      | User Test          |
      | Dummy User         |

    # Case: No users found.
    When I set the field "Search users" to "Plagiarism"
    And I should see "No results for \"Plagiarism\""
    # Table remains unchanged as the user had no results to select from the dropdown.
    And the following should exist in the "user-grades" table:
      | -1-                |
      | Turtle Manatee     |
    And the following should not exist in the "user-grades" table:
      | -1-                |
      | Teacher 1          |
      | Student 1          |
      | User Example       |
      | User Test          |
      | Dummy User         |

    # Case: Multiple users found and select only one result.
    Then I set the field "Search users" to "User"
    And I wait until "View all results (3)" "option_role" exists
    And "Dummy User" "list_item" should exist in the ".user-search" "css_element"
    And "User Example" "list_item" should exist in the ".user-search" "css_element"
    And "User Test" "list_item" should exist in the ".user-search" "css_element"
    And "Turtle Manatee" "list_item" should not exist in the ".user-search" "css_element"
    # Check if the matched field names (by lines) includes some identifiable info to help differentiate similar users.
    And "User (student2@example.com)" "list_item" should exist in the ".user-search" "css_element"
    And "User (student3@example.com)" "list_item" should exist in the ".user-search" "css_element"
    And "User (student4@example.com)" "list_item" should exist in the ".user-search" "css_element"
    And I click on "Dummy User" "list_item"
    And I wait until the page is ready
    And the following should exist in the "user-grades" table:
      | -1-                |
      | Dummy User         |
    And the following should not exist in the "user-grades" table:
      | -1-                |
      | Teacher 1          |
      | Student 1          |
      | User Example       |
      | User Test          |
      | Turtle Manatee     |

    # Business case: When searching with multiple partial matches, show the matches in the dropdown + a "View all results for (Bob)"
    # Business case cont. When pressing enter with multiple partial matches, behave like when you select the "View all results for (Bob)"
    # Case: Multiple users found and select all partial matches.
    And I set the field "Search users" to "User"
    And I wait until "View all results (3)" "option_role" exists
    # Dont need to check if all users are in the dropdown, we checked that earlier in this test.
    And "View all results (3)" "option_role" should exist
    And I click on "View all results (3)" "option_role"
    And I wait until the page is ready
    And the following should exist in the "user-grades" table:
      | -1-                |
      | Dummy User         |
      | User Example       |
      | User Test          |
    And the following should not exist in the "user-grades" table:
      | -1-                |
      | Teacher 1          |
      | Student 1          |
      | Turtle Manatee     |
    And I click on "Clear" "link" in the ".user-search" "css_element"
    And I wait until the page is ready
    And the following should exist in the "user-grades" table:
      | -1-                |
      | Turtle Manatee     |
      | Student 1          |
      | User Example       |
      | User Test          |
      | Dummy User         |

  Scenario: A teacher can quickly tell that a search is active on the current table
    Given I set the field "Search users" to "Turtle"
    And I wait until "View all results (1)" "option_role" exists
    And I click on "Turtle Manatee" "list_item"
    And I wait until the page is ready
    # The search input remains in the field on reload this is in keeping with other search implementations.
    When the field "Search users" matches value "Turtle"
    And "View all results (1)" "link" should not exist
    # Test if we can then further retain the turtle result set and further filter from there.
    Then I set the field "Search users" to "Turtle plagiarism"
    And "Turtle Manatee" "list_item" should not exist
    And I should see "No results for \"Turtle plagiarism\""

  Scenario: A teacher can search for values besides the users' name
    Given I set the field "Search users" to "student5@example.com"
    And I wait until "View all results (1)" "option_role" exists
    And "Turtle Manatee" "list_item" should exist
    And I set the field "Search users" to "@example.com"
    And I wait until "View all results (5)" "option_role" exists
    # Note: All learners match this email & showing emails is current default.
    And "Dummy User" "list_item" should exist in the ".user-search" "css_element"
    And "User Example" "list_item" should exist in the ".user-search" "css_element"
    And "User Test" "list_item" should exist in the ".user-search" "css_element"
    And "Student 1" "list_item" should exist in the ".user-search" "css_element"
    And "Turtle Manatee" "list_item" should exist in the ".user-search" "css_element"

    # Search on the country field.
    When I set the field "Search users" to "JP"
    And I wait until "Turtle Manatee" "list_item" does not exist
    And "Dummy User" "list_item" should exist in the ".user-search" "css_element"
    And "User Test" "list_item" should exist in the ".user-search" "css_element"

    # Search on the city field.
    And I set the field "Search users" to "Hanoi"
    And I wait until "User Test" "list_item" does not exist
    Then "Student 1" "list_item" should exist in the ".user-search" "css_element"

    # Search on the institution field.
    And I set the field "Search users" to "ABCD"
    And I wait until "Dummy User" "list_item" exists
    And "User Example" "list_item" should exist in the ".user-search" "css_element"
    And "User Test" "list_item" should exist in the ".user-search" "css_element"
    And "Student 1" "list_item" should exist in the ".user-search" "css_element"
    And "Turtle Manatee" "list_item" should exist in the ".user-search" "css_element"

      # Search on the department field.
    And I set the field "Search users" to "ABC3"
    And I wait until "User Example" "list_item" does not exist
    And "User Test" "list_item" should exist in the ".user-search" "css_element"
    And "Turtle Manatee" "list_item" should exist in the ".user-search" "css_element"

    # Search on the phone1 field.
    And I set the field "Search users" to "4365899871"
    And I wait until "User Test" "list_item" does not exist
    And "Dummy User" "list_item" should exist in the ".user-search" "css_element"

    # Search on the phone2 field.
    And I set the field "Search users" to "2149871323"
    And I wait until "Dummy User" "list_item" does not exist
    And "User Test" "list_item" should exist in the ".user-search" "css_element"

    # Search on the institution field then press enter to show the record set.
    And I set the field "Search users" to "ABC"
    And I wait until "Turtle Manatee" "list_item" exists
    And "Dummy User" "list_item" should exist in the ".user-search" "css_element"
    And "User Example" "list_item" should exist in the ".user-search" "css_element"
    And "User Test" "list_item" should exist in the ".user-search" "css_element"
    And "Student 1" "list_item" should exist in the ".user-search" "css_element"
    And I press the enter key
    And I wait until the page is ready
    And the following should exist in the "user-grades" table:
      | -1-                |
      | Student 1          |
      | User Example       |
      | User Test          |
      | Dummy User         |
      | Turtle Manatee     |
    And the following should not exist in the "user-grades" table:
      | -1-                |
      | Teacher 1          |

  @accessibility
  Scenario: A teacher can set focus and search using the input are with a keyboard
    # Basic tests for the page.
    Given the page should meet accessibility standards
    And the page should meet "wcag131, wcag141, wcag412" accessibility standards
    And the page should meet accessibility standards with "wcag131, wcag141, wcag412" extra tests
    # Move onto general keyboard navigation testing.
    And I press the tab key
    And the focused element is "Search users" "field"
    When I set the field "Search users" to "ABC"
    And I wait until "Turtle Manatee" "option_role" exists
    And I press the down key
    And the focused element is "Student 1" "option_role"
    And I press the end key
    And the focused element is "View all results (5)" "option_role"
    And I press the home key
    And the focused element is "Student 1" "option_role"
    And I press the up key
    And the focused element is "View all results (5)" "option_role"
    And I press the down key
    And the focused element is "Student 1" "option_role"
    And I press the escape key
    And the focused element is "Search users" "field"
    Then I set the field "Search users" to "Goodmeme"
    And I press the down key
    And the focused element is "Search users" "field"

    And I navigate to "View > Grader report" in the course gradebook
    And I set the field "Search users" to "ABC"
    And I wait until "Turtle Manatee" "option_role" exists
    And I press the down key
    And the focused element is "Student 1" "option_role"

    # Lets check the tabbing order.
    And I set the field "Search users" to "ABC"
    And I wait until "View all results (5)" "option_role" exists
    And I press the tab key
    And the focused element is "Clear search input" "button"
    And I press the tab key
    And the focused element is "View all results (5)" "option_role"
    And I press the tab key
    And the focused element is ".search-widget[data-searchtype='group'] [data-toggle='dropdown']" "css_element"
    # Ensure we can interact with the input & clear search options with the keyboard.
    # Space & Enter have the same handling for triggering the two functionalities.
    And I set the field "Search users" to "User"
    And I click on ".usersearchwidget [data-action=search]" "css_element"
    And I press the enter key
    And I wait to be redirected
    And the following should exist in the "user-grades" table:
      | -1-                |
      | Dummy User         |
      | User Example       |
      | User Test          |
    And the following should not exist in the "user-grades" table:
      | -1-                |
      | Teacher 1          |
      | Student 1          |
      | Turtle Manatee     |
    # Sometimes with behat we get unattached nodes causing spurious failures.
    And I wait "1" seconds
    And I set the field "Search users" to "ABC"
    And I wait until "Turtle Manatee" "option_role" exists
    And I press the tab key
    And the focused element is "Clear search input" "button"
    And I press the enter key
    And I wait until the page is ready
    And I should not see "Turtle Manatee" in the ".user-search" "css_element"

  Scenario: Once a teacher searches, it'll apply the currently set filters and inform the teacher as such
    # Set up a basic filtering case.
    Given I press "Filter by name"
    And I select "U" in the "First name" "core_grades > initials bar"
    And I select "E" in the "Last name" "core_grades > initials bar"
    And I press "Apply"
    And I wait until the page is ready
    And the following should exist in the "user-grades" table:
      | -1-                |
      | User Example       |
    And the following should not exist in the "user-grades" table:
      | -1-                |
      | Teacher 1          |
      | Student 1          |
      | User Test          |
      | Dummy User         |
      | Turtle Manatee     |

    # Begin the search checking if we are adhering the filters.
    When I set the field "Search users" to "Turtle"
    Then "Turtle Manatee" "list_item" should not exist in the ".user-search" "css_element"

  Scenario: As a teacher I can dynamically find users whilst ignoring pagination
    Given "42" "users" exist with the following data:
      | username  | students[count]             |
      | firstname | Student                     |
      | lastname  | s[count]                    |
      | email     | students[count]@example.com |
    And "42" "course enrolments" exist with the following data:
      | user   | students[count] |
      | course | C1              |
      | role   |student          |
    And I reload the page
    And the field "perpage" matches value "20"
    When I set the field "Search users" to "42"
    # One of the users' phone numbers also matches.
    And I wait until "View all results (2)" "link" exists
    Then "Student s42" "list_item" should exist in the ".user-search" "css_element"
