package JIRA::Client::REST;
{
  $JIRA::Client::REST::VERSION = '0.07';
}

use Carp;
use Moose;

# ABSTRACT: JIRA REST Client V2

use JSON qw(decode_json encode_json);
use Net::HTTP::Spore;


has '_client' => (
    is => 'rw',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $api_version = $self->api_version;
        my $api_uri_prefix = $self->api_prefix;
        my $require_payload = $self->api_version < 2 ? 0 : 1;
 
        my $client_str = <<"EOC";
            {
                "name": "JIRA",
                "authority": "GITHUB:gphat",
                "version": "${api_version}",
                "methods": {
                    "get_issue": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "optional_params": [
                            "fields",
                            "expand"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "create_issue": {
                        "path": "${api_uri_prefix}/issue",
                        "required_payload": 1,
                        "method": "POST",
                        "authentication": true
                    },
                    "update_issue": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "required_payload": 1,
                        "method": "PUT",
                        "authentication": true
                    },
                    "delete_issue": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey",
                        "required_params": [
                            "issueIdOrKey",
                            "deleteSubtasks"
                        ],
                        "method": "DELETE",
                        "authentication": true
                    },
					"assign_issue": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/assignee",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "required_payload": 1,
                        "method": "PUT",
                        "authentication": true
                    },
                    "get_issue_transitions": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/transitions",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "optional_params": [
                            "transitionId",
                            "expand"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_issue_votes": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/votes",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                         "optional_params": [
                            "expand"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_issue_watchers": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/watchers",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                         "optional_params": [
                            "expand"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_project": {
                        "path": "${api_uri_prefix}/project/:key",
                        "required_params": [
                            "key"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_project_versions": {
                        "path": "${api_uri_prefix}/project/:key/versions",
                        "required_params": [
                            "key"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_version": {
                        "path": "${api_uri_prefix}/version/:id",
                        "required_params": [
                            "id"
                        ],
                        "optional_params": [
                            "expand"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "unvote_for_issue": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/votes",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "method": "DELETE",
                        "authentication": true
                    },
                    "unwatch_issue": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/watchers",
                        "required_params": [
                            "issueIdOrKey",
                            "username"
                        ],
                        "method": "DELETE",
                        "authentication": true
                    },
                    "vote_for_issue": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/votes",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "method": "POST",
                        "authentication": true
                    },
                    "watch_issue": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/watchers",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "optional_params": [
                            "username"
                        ],
                        "method": "POST",
                        "required_payload" : ${require_payload},
                        "authentication": true
                    },
					"get_issue_comments": {
						"path": "${api_uri_prefix}/issue/:issueIdOrKey/comment",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "optional_params": [
                            "expand"
                        ],
                        "method": "GET",
                        "authentication": true
					},
                    "add_comment": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/comment",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "optional_params": [
                            "expand"
                        ],
                        "required_payload": 1,
                        "method": "POST",
                        "authentication": true
                    },
					"edit_comment": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/comment/:id",
                        "required_params": [
                            "issueIdOrKey",
							"id"
                        ],
                        "optional_params": [
                            "expand"
                        ],
                        "required_payload": 1,
                        "method": "PUT",
                        "authentication": true
                    },
					"delete_comment": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/comment/:id",
                        "required_params": [
                            "issueIdOrKey",
							"id"
                        ],
                        "method": "DELETE",
                        "authentication": true
                    },
                    "issue_transition_action": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/transitions",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "required_payload": 1,
                        "method": "POST",
                        "authentication": true
                    },
                    "get_statuses": {
                        "path": "${api_uri_prefix}/status",
                        "method": "GET",
                        "authentication": true
                    },
                    "get_fields": {
                        "path": "${api_uri_prefix}/field",
                        "method": "GET",
                        "authentication": true
                    },
                    "get_issue_editmeta": {
                        "path": "${api_uri_prefix}/issue/:issueIdOrKey/editmeta",
                        "required_params": [
                            "issueIdOrKey"
                        ],
                        "method": "GET",
                        "authentication": true
                    }
                }
            }
EOC
        # In order to support PUT/PATCH HTTP Method, Net::HTTP::Spore needs 
        # version 0.06
        my $client = Net::HTTP::Spore->new_from_string($client_str,
            base_url => $self->url,
            trace => $self->debug,
        );
        $client->enable('Format::JSON');
        $client->enable('Auth::Basic', username => $self->username, password => $self->password);
        return $client;
    }
);

has 'debug' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);


has 'password' => (
    is => 'rw',
    isa => 'Str',
    required => 1
);


has 'url' => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

has 'api_version' => (
    is => 'rw',
    isa => 'Str',
    default => '2.0' 
);

has 'api_prefix' => (
    is => 'rw',
    isa => 'Str',
    default => '/rest/api/latest'
);

has 'username' => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

sub _get_resp {
    my ($self, $resp) = @_;

    # For convinence, return the body content if succeed,
    # otherwise return the raw response data
    if ($resp->{status} >= 200 and $resp->{status} < 300) {
        return exists $resp->{body} ? $resp->{body} : {};
    }
    else {
        return $resp;
    }
}

sub get_issue {
    my ($self, $issueIdOrKey, $expand) = @_;

    my $resp = $self->_client->get_issue(issueIdOrKey => $issueIdOrKey, expand => $expand);

    return $self->_get_resp($resp);
}

sub create_issue {
    my ($self, $payload) = @_;

    # Example payload to repsent an Issue. Refer to https://docs.atlassian.com/jira/REST/latest/#id163684
	#	{
	#	"update": {
	#		"worklog": [
	#			{
	#				"add": {
	#					"started": "2011-07-05T11:05:00.000+0000",
	#					"timeSpent": "60m"
	#				}
	#			}
	#		]
	#	},
	#	"fields": {
	#		"project": {
	#			"id": "10000"
	#		},
	#		"summary": "something's wrong",
	#		"issuetype": {
	#			"id": "10000"
	#		},
	#		...
	#		}
	#	}

	my $resp = $self->_client->create_issue(payload => $payload);

    return $self->_get_resp($resp);
}

sub delete_issue {
	my ($self, $issueIdOrKey, $deleteSubtasks) = @_;
	
	my $resp = $self->_client->delete_issue(issueIdOrKey => $issueIdOrKey, deleteSubtasks => $deleteSubtasks);
	
	return $self->_get_resp($resp);
}

sub update_issue {
    my ($self, $issueIdOrKey, $payload) = @_;
    # The format of payload
    # {
    #     "update": {
    #          "summary": [
    #               {
    #                   "set": "Bug in business logic"
    #               }
    #           ],
    #           "labels": [
    #               {
    #                   "add": "triaged"
    #               },
    #               {
    #                   "remove": "blocker"
    #               }
    #           ],
    #           "components": [
    #               {
    #                   "set": ""
    #               }
    #           ]
    #       }
    #   }
    # or the simple way
    # { "fields":{"field_name":"value"}}

    my $resp = $self->_client->update_issue(issueIdOrKey => $issueIdOrKey, payload => $payload);

    return $self->_get_resp($resp);
}

sub assign_issue {
	my ($self, $issueIdOrKey, $payload) = @_;
    # The json format of payload for request representation
    # {
    #     "name": "harry"
	# }

    my $resp = $self->_client->assign_issue(issueIdOrKey => $issueIdOrKey, payload => $payload);

    return $self->_get_resp($resp);
}

sub get_issue_transitions {
    my ($self, $issueIdOrKey, $transitionId, $expand) = @_;
    $transitionId ||= "";
    $expand ||= "transitions.fields"; 

    my $resp = $self->_client->get_issue_transitions(issueIdOrKey => $issueIdOrKey, transitionId => $transitionId, expand => $expand);

    return $self->_get_resp($resp);
}

sub get_issue_votes {
    my ($self, $issueIdOrKey, $expand) = @_;

    my $resp = $self->api_version < 2 ? $self->_client->get_issue_votes(issueIdOrKey => $issueIdOrKey, expand => $expand) : 
         $self->_client->get_issue_votes(issueIdOrKey => $issueIdOrKey);

    return $self->_get_resp($resp);
}

sub get_issue_watchers {
    my ($self, $issueIdOrKey, $expand) = @_;

    my $resp = $self->api_verson eq '1.0' ? $self->_client->get_issue_watchers(issueIdOrKey => $issueIdOrKey, expand => $expand) : 
            $self->_client->get_issue_watchers(issueIdOrKey => $issueIdOrKey);

    return $self->_get_resp($resp);
}

sub get_project {
    my ($self, $key) = @_;
    
    my $resp = $self->_client->get_project(key => $key);

    return $self->_get_resp($resp);
}


sub get_project_versions {
    my ($self, $key) = @_;
    
    my $resp = $self->_client->get_project_versions(key => $key);

    return $self->_get_resp($resp);
}


sub get_version {
    my ($self, $id, $expand) = @_;
    
    my $resp = $self->api_version < 2 ? $self->_client->get_version(id => $id) : 
                 $self->_client->get_version(id => $id, expand => $expand);

    return $self->_get_resp($resp);
}


sub unvote_for_issue {
    my ($self, $issueIdOrKey) = @_;

    my $resp = $self->_client->unvote_for_issue(issueIdOrKey => $issueIdOrKey);

    return $self->_get_resp($resp);
}


sub unwatch_issue {
    my ($self, $issueIdOrKey, $username) = @_;

    my $resp = $self->_client->unwatch_issue(issueIdOrKey => $issueIdOrKey, username => $username);

    return $self->_get_resp($resp);
}


sub vote_for_issue {
    my ($self, $issueIdOrKey) = @_;

    my $resp =$self->_client->vote_for_issue(issueIdOrKey => $issueIdOrKey);

    return $self->_get_resp($resp);
}


sub watch_issue {
    my ($self, $issueIdOrKey, $username) = @_;
    my $opt_param = $self->api_version < 2 ? "username" : "payload";

    my $resp = $self->_client->watch_issue(issueIdOrKey => $issueIdOrKey, $opt_param => $username);

    return $self->_get_resp($resp);
}

sub get_issue_comments {
	my ($self, $issueIdOrKey, $expand) = @_;
	
	my $resp = $self->_client->get_comments(issueIdOrKey => $issueIdOrKey, expand => $expand);
	
	return $self->_get_resp($resp);
}

sub add_comment {
    my ($self, $issueIdOrKey, $payload, $expand) = @_;
    # The json format of payload
    # {
    #   "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    #           " Pellentesque eget venenatis elit. Duis eu justo eget augue "
    #           "iaculis fermentum. Sed semper quam laoreet nisi egestas at posuere augue semper.",
    #   "visibility": {
    #           "type": "role",
    #           "value": "Administrators"
    #       }
    # }

    my $resp = $self->_client->add_comment(issueIdOrKey => $issueIdOrKey, payload => $payload, expand => $expand);

    return $self->_get_resp($resp);
}

sub edit_comment {
	my ($self, $issueIdOrKey, $id, $payload, $expand) = @_;
    # The json format of payload
    # {
    #   "body": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    #           " Pellentesque eget venenatis elit. Duis eu justo eget augue "
    #           "iaculis fermentum. Sed semper quam laoreet nisi egestas at posuere augue semper.",
    #   "visibility": {
    #           "type": "role",
    #           "value": "Administrators"
    #       }
    # }

    my $resp = $self->_client->edit_comment(issueIdOrKey => $issueIdOrKey, id => $id, 
									payload => $payload, expand => $expand);

    return $self->_get_resp($resp);
}

sub delete_comment {
	my ($self, $issueIdOrKey, $id) = @_;

    my $resp = $self->_client->delete_comment(issueIdOrKey => $issueIdOrKey, id => $id);

    return $self->_get_resp($resp);
}

sub issue_transition_action_safely {
    my ($self, $issueIdOrKey, $payload) = @_;

    # payload should be look like this
    # { "update": {
    #         "comment": [
    #           {"add": {"body":"Bug fixed."}}
    #          ]
    #     },
    #   "fields": {
    #         "assignee": {"name": "bob"},
    #         "resolution": {"name": "Fixed"}
    #     },
    #   "transition" {
    #         "id": "5"
    #     }
    # }

    my $issue_transitions = $self->get_issue_transitions($issueIdOrKey);

    # Check the destination transition is ID or name
    if($payload->{transition}->{id} =~ /\D/) {
        my @available_transitions = @{$issue_transitions->{transitions}};
        my @named_transition = grep {$payload->{transition}->{id} eq $_->{name}} @available_transitions;
        if(@named_transition) {
            $payload->{transition}->{id} = $named_transition[0]->{id};
        }
        else {
            croak "Unavailable transition (" .  $payload->{transition}->{id} . ").\n"; 
        }
    }

    # Make sure $params contains all the fields that are present in
    # the action screen.
    my $issue;
    my @fields = @{$issue_transitions->{fields}};
    foreach my $id (map {$_->{id}} @fields) {
        # This is due to a bug in JIRA
        # http://jira.atlassian.com/browse/JRA-12300
        $id = 'affectsVersions' if $id eq 'versions';

        next if exists $payload->{fields}->{$id};

        my $issue = $self->get_issue($issueIdOrKey) unless defined $issue;
        if (exists $issue->{$id}) {
            $payload->{fields}->{$id} = $issue->{$id} if defined $issue->{$id};
        }
        else {
            foreach my $cf (@{$issue->{customFieldValues}}) {
                if ($cf->{customfieldId} eq $id) {
                    $payload->{fields}->{$id} = $cf->{values};
                    last;
                }
            }
            # NOTE: It's not a problem if we can't find a missing
            # parameter in the issue. It will simply stay undefined.
        }
    }    

    my $resp = $self->_client->issue_transition_action(issueIdOrKey => $issueIdOrKey, payload => $payload);

    return $self->_get_resp($resp);
}

sub issue_transition_action {
    my ($self, $issueIdOrKey, $to) = @_;

    # Check the destination transition is ID or name
    if($to =~ /\D/) {
        my $issue_transitions = $self->get_issue_transitions($issueIdOrKey);
        my @available_transitions = @{$issue_transitions->{transitions}};
        my @named_transition = grep {$to eq $_->{name}} @available_transitions;
        if(@named_transition) {
            $to = $named_transition[0]->{id};
        }
        else {
            croak "Unavailable transition (" . $to . ").\n";
        }
    }

    my $payload = {"transition" => {"id" => $to}};
    my $resp = $self->_client->issue_transition_action(issueIdOrKey => $issueIdOrKey, payload => $payload);

    return $self->_get_resp($resp);
}

sub get_statuses {
    my ($self) = @_;

    my $resp = $self->_client->get_statuses();

    return $self->_get_resp($resp);
}

sub get_fields {
    my ($self) = @_;
    
    my $resp = $self->_client->get_fields();

    return $self->_get_resp($resp);
}

sub get_issue_editmeta {
    my ($self, $issueIdOrKey) = @_;

    my $resp = $self->_client->get_issue_editmeta(issueIdOrKey => $issueIdOrKey);

    return $self->_get_resp($resp);
}
1;

__END__
=pod

=head1 NAME

JIRA::Client::REST - JIRA REST Client for Verions 2 REST API of JIRA

=head1 VERSION

version 0.07

=head1 SYNOPSIS

    use JIRA::Client::REST;

    my $client = JIRA::Client::REST->new(
        username => 'username',
        password => 'password',
        url => 'http://jira.mycompany.com',
        api_version => '2.0',
        api_prefix => '/rest/api/2'
    );
    my $issue = $client->get_issue('TICKET-12');
    print $issue->{fields}->{priority}->{value}->{name}."\n";

=head1 DESCRIPTION

JIRA::Client::REST is a wrapper for the L<JIRA REST API|https://docs.atlassian.com/jira/REST/latest/>.
It is a thin wrapper, returning decoded version of the JSON without any munging
or mangling.

=head1 HEADS UP

This module is under development and some of the REST API hasn't been implemented
yet.

=head1 ATTRIBUTES

=head2 password

Set/Get the password to use when connecting to JIRA.

=head2 url

Set/Get the URL for the JIRA instance.

=head2 username

Set/Get the username to use when connecting to JIRA.

=head2 api_version

Set/Get the version of JIRA REST API to use. Default value: 2.0.

=head2 api_prefix

Set/Get the URL prefix of JIRA REST API which will be used to construct the whole REST API URL(No slash at the end). Default value: /rest/api/latest 
=head1 METHODS

=head2 get_issue($issueIdOrKey, $expand)

Get the issue with the supplied id or key.  Returns a HashRef of data.

=head2 get_issue_transitions($issueIdOrKey, $transitionId, $expand)

Get the transitions possible for this issue by the current user.

=head2 get_issue_votes($issueIdOrKey)

Get voters on the issue. Notes: In version 1 API, get_issue_votes() support "expand" argument.

=head2 get_issue_watchers($issueIdOrKey)

Get watchers on the issue. In version 1 API, get_issue_watchers() support "expand" argument.

=head2 get_project($key)

Get the project for the specifed key.

=head2 get_project_versions($key)

Get the versions for the project with the specified key.

=head2 get_version($id, $expand)

Get the version with the specified id. Notes: "expand" argument is supported by version 2 API of JIRA.

=head2 unvote_for_issue($issueIdOrKey)

Remove your vote from an issue.

=head2 unwatch_issue($issueIdOrKey, $username)

Remove a watcher from an issue.

=head2 vote_for_issue($issueIdOrKey)

Cast your vote in favor of an issue.

=head2 watch_issue($issueIdOrKey, $username)

Watch an issue. (Or have someone else watch it.)

=head2 create_issue($payload)

Createa an issue from a JSON representation, which is apayload, 
referring to https://docs.atlassian.com/jira/REST/latest/#id163684 for details.

=head2 update_issue($issueIdOrKey, $updates)

Edits an issue from a JSON representation.

=head2 delete_issue($issueIdOrKey, $deleteSubtasks)

Deletes an issue. If the issue has subtasks you must set the parameter deleteSubtasks=true to delete the issue. 
You cannot delete an issue without its subtasks also being deleted.

=head2 assign_issue($issueIdOrKey, $payload)

Assigns an issue to a use. Payload is a JSON format to represent a user. {"name":"harry"}.

=head2 issue_transition_action($issueIdOrKey, $transitionIdOrName)

Performs a transition on an issue.

=head2 get_issue_comments($issueIdOrKey, $expand)

Gets all comments of an issue.

=head2 add_comment($issueIdOrKey, $comment, $expand)

Adds a new comment to an issue.

=head2 edit_comment($issueIdOrKey, $id, $payload, $expand)

Edits an existing comment of an issue.

=head2 delete_comment($issueIdOrKey, $id)

Deletes an existing comment of an issue.

=head2 get_statuses()

Returns a list of all statuses.

=head2 get_fields()

Get all fields, including system and custom fields.

=head2 get_issue_editmeta($issueIdOrKey)

Get the meta data for editing an issue.

=head1 AUTHOR

Cory G Watson <gphat@cpan.org>
Grant Street Group <cpan@grantstreet.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Cold Hard Code, LLC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

