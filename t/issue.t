use strict;
use Test::More;
use JIRA::Client::REST;

if(!$ENV{JIRA_CLIENT_REST_URL}) {
    plan skip_all => 'Set JIRA_CLIENT_REST_URL';
}

my $client = JIRA::Client::REST->new(
    username => $ENV{JIRA_CLIENT_REST_USER},
    password => $ENV{JIRA_CLIENT_REST_PASS},
    url => $ENV{JIRA_CLIENT_REST_URL},
    debug => 1
);
my $issue = $client->get_issue('TESTING-39');
cmp_ok($issue->{fields}->{priority}->{value}->{name}, 'eq', 'Minor', 'get_issue');

my $trans = $client->get_issue_transitions('TESTING-39');
cmp_ok($trans->{761}->{name}, 'eq', 'Stop Progress', 'get_issue_transitions');

my $votes = $client->get_issue_votes('TESTING-39');
cmp_ok($votes->{votes}, '==', 0, 'get_issue_votes');

cmp_ok($client->vote_for_issue('TESTING-1'), 'eq', '', 'vote_for_issue');

cmp_ok($client->unvote_for_issue('TESTING-1'), 'eq', '', 'vote_for_issue');

my $watchers = $client->get_issue_watchers('TESTING-39');
cmp_ok($watchers->{watchCount}, '==', 0, 'get_issue_watchers');

cmp_ok($client->watch_issue('TESTING-1', 'cory.watson'), 'eq', '', 'watch_issue');

cmp_ok($client->unwatch_issue('TESTING-1', 'cory.watson'), 'eq', '', 'unwatch_issue');

my $issue_to_create = {"update": {
                            "worklog": [
                                    {
                                        "add": {
                                            "started": "2013-06-05T11:05:00.000+0000",
                                            "timeSpent": "60m"
                                            }
                                     }
                                ]
                            },
                        "fields": {
                            "project": {"id": "10001"},
                            "summary": "something's wrong",
                            "issuetype": {"id": "10000"},
                            "assignee": {"name": "homer"},
                            "reporter": {"name": "smithers"},
                            "priority": {"id": "20000"},
                            "labels": [
                                        "bugfix",
                                        "blitz_test"
                                      ],
                            "timetracking": {
                                        "originalEstimate": "10",
                                        "remainingEstimate": "5"
                            },
                            "security": {"id": "10000"},
                            "versions": [
                                            {"id": "10000"}
                                        ],
                            "environment": "environment",
                            "description": "description",
                            "duedate": "2013-06-11"
                        }
                    };

cmp_ok($client->create_issue($issue_to_create)->{id}, '>=', 0, 'create_issue');

my $issue_to_update = { "fields":{"summary":"summary"}};
cmp_ok($client->update_issue('TESTING-1', $issue_to_update), 'eq', '', 'update_issue');

cmp_ok($client->assign_issue('TESTING-1', {"name":"ijab"}), 'eq', '', 'assign_issue');
  
cmp_ok($client->issue_transition_action('TESTING-1', 'Closed'), 'eq', '', 'issue_transition_action');

$fields = $client->get_issue_editmeta('TESTING-1');
ok(scalar(@{ $fields->{fields} }) >= 0, 'get_issue_editmeta');

cmp_ok($client->delete_issue('TESTING-1', 'true'), 'eq', '', 'delete_issue');

done_testing;
