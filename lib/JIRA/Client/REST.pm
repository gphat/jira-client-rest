package JIRA::Client::REST;
use Moose;

# ABSTRACT: JIRA REST Client

use JSON qw(decode_json encode_json);
use Net::HTTP::Spore;

=head1 DESCRIPTION

JIRA::Client::REST is a wrapper for the L<JIRA REST API|http://docs.atlassian.com/jira/REST/latest/>.
It is a thin wrapper, returning decoded version of the JSON without any munging
or mangling.

=head1 SYNOPSIS

    use JIRA::Client::REST;

    my $client = JIRA::Client::REST->new(
        username => 'username',
        password => 'password',
        url => 'http://jira.mycompany.com',
    );
    my $issue = $client->get_issue('TICKET-12');
    print $issue->{fields}->{priority}->{value}->{name}."\n";

=begin :prelude

=head1 HEADS UP

This module is under development and some of the REST API hasn't been implemented
yet.

=end :prelude

=cut

has '_client' => (
    is => 'rw',
    lazy => 1,
    default => sub {
        my $self = shift;

        my $client = Net::HTTP::Spore->new_from_string(
            '{
                "name": "JIRA",
                "authority": "GITHUB:gphat",
                "version": "1.0",
                "methods": {
                    "get_issue": {
                        "path": "/rest/api/latest/issue/:id",
                        "required_params": [
                            "id"
                        ],
                        "optional_params": [
                            "expand"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_issue_transitions": {
                        "path": "/rest/api/latest/issue/:id/transitions",
                        "required_params": [
                            "id"
                        ],
                        "optional_params": [
                            "expand"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_issue_votes": {
                        "path": "/rest/api/latest/issue/:id/votes",
                        "required_params": [
                            "id"
                        ],
                        "optional_params": [
                            "expand"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_issue_watchers": {
                        "path": "/rest/api/latest/issue/:id/watchers",
                        "required_params": [
                            "id"
                        ],
                        "optional_params": [
                            "expand"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_project": {
                        "path": "/rest/api/latest/project/:key",
                        "required_params": [
                            "key"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_projects": {
                        "path": "/rest/api/latest/project",
                        "method": "GET",
                        "authentication": true
                    },
                    "get_project_versions": {
                        "path": "/rest/api/latest/project/:key/versions",
                        "required_params": [
                            "key"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_version": {
                        "path": "/rest/api/latest/version/:id",
                        "required_params": [
                            "id"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "get_filter": {
                        "path": "/rest/api/latest/filter/:id",
                        "required_params": [
                            "id"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "search": {
                        "path": "/rest/api/latest/search",
                        "required_params": [
                            "jql"
                        ],
                        "optional_params": [
                            "startAt", "maxResults", "fields", "expand"
                        ],
                        "method": "GET",
                        "authentication": true
                    },
                    "add_comment": {
                        "path": "/rest/api/latest/issue/:id/comment",
                        "payload_is_required": true,
                        "optional_params": [
                            "expand"
                        ],
                        "method": "POST",
                        "authentication": true
                    },
                    "unvote_for_issue": {
                        "path": "/rest/api/latest/issue/:id/votes",
                        "required_params": [
                            "id"
                        ],
                        "method": "DELETE",
                        "authentication": true
                    },
                    "unwatch_issue": {
                        "path": "/rest/api/latest/issue/:id/watchers",
                        "required_params": [
                            "id",
                            "username"
                        ],
                        "method": "DELETE",
                        "authentication": true
                    },
                    "vote_for_issue": {
                        "path": "/rest/api/latest/issue/:id/votes",
                        "required_params": [
                            "id"
                        ],
                        "method": "POST",
                        "authentication": true
                    },
                    "watch_issue": {
                        "path": "/rest/api/latest/issue/:id/watchers",
                        "required_params": [
                            "id",
                            "username"
                        ],
                        "method": "POST",
                        "authentication": true
                    }
                }
            }',
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

=attr password

Set/Get the password to use when connecting to JIRA.

=cut

has 'password' => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

=attr url

Set/Get the URL for the JIRA instance.

=cut

has 'url' => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

=attr username

Set/Get the username to use when connecting to JIRA.

=cut

has 'username' => (
    is => 'rw',
    isa => 'Str',
    required => 1
);

=method get_issue($id, $expand)

Get the issue with the supplied id.  Returns a HashRef of data.

=cut

sub get_issue {
    my ($self, $id, $expand) = @_;

    return $self->_client->get_issue(id => $id, expand => $expand);
}

=method get_issue_transitions($id, $expand)

Get the transitions possible for this issue by the current user.

=cut

sub get_issue_transitions {
    my ($self, $id, $expand) = @_;

    return $self->_client->get_issue_transitions(id => $id, expand => $expand);
}

=method get_issue_votes($id, $expand)

Get voters on the issue.

=cut

sub get_issue_votes {
    my ($self, $id, $expand) = @_;

    return $self->_client->get_issue_votes(id => $id, expand => $expand);
}

=method get_issue_watchers($id, $expand)

Get watchers on the issue.

=cut

sub get_issue_watchers {
    my ($self, $id, $expand) = @_;

    return $self->_client->get_issue_watchers(id => $id, expand => $expand);
}

=method get_project($key)

Get the project for the specifed key.

=cut

sub get_project {
    my ($self, $key) = @_;
    
    return $self->_client->get_project(key => $key);
}

=method get_projects()

Gets all the projects

=cut

sub get_projects {
    my ($self) = @_;
    
    return $self->_client->get_projects();
}

=method get_project_versions($key)

Get the versions for the project with the specified key.

=cut

sub get_project_versions {
    my ($self, $key) = @_;
    
    return $self->_client->get_project_versions(key => $key);
}

=method get_version($id)

Get the version with the specified id.

=cut

sub get_version {
    my ($self, $id) = @_;
    
    return $self->_client->get_version(id => $id);
}

=method get_filter($id)

Gets filter metadata, use the jql field to perform a search to get issues

=cut

sub get_filter {
    my ($self, $id) = @_;

    return $self->_client->get_filter(id => $id);
}

=method search($jql, $startAt, $maxResults, $fields $expand)

Searches for issues using JQL.

=cut

sub search {
    my ($self, $jql, $startAt, $maxResults, $fields, $expand) = @_;

	my @param = (jql => $jql);

	push @param, (startAt=>$startAt) if $startAt;
	push @param, (maxResults=>$maxResults) if $maxResults;
	push @param, (fields=>$fields) if $fields;
	push @param, (expand=>$expand) if $expand;
	
	return $self->_client->search(@param);
}

=method add_comment($id, $comment, $expand)

Adds a comment to an issue

=cut

sub add_comment {
    my ($self, $id, $comment, $expand) = @_;

	my @param = (id => $id, spore_payload=>{body=>$comment});
	push @param, (expand=>$expand) if $expand;

	return $self->_client->add_comment(@param);
}

=method unvote_for_issue($id)

Remove your vote from an issue.

=cut

sub unvote_for_issue {
    my ($self, $id) = @_;

    return $self->_client->unvote_for_issue(id => $id);
}

=method unwatch_issue($id, $username)

Remove a watcher from an issue.

=cut

sub unwatch_issue {
    my ($self, $id, $username) = @_;

    return $self->_client->unwatch_issue(id => $id, username => $username);
}

=method vote_for_issue($id)

Cast your vote in favor of an issue.

=cut

sub vote_for_issue {
    my ($self, $id) = @_;

    return $self->_client->vote_for_issue(id => $id);
}

=method watch_issue($id, $username)

Watch an issue. (Or have someone else watch it.)

=cut

sub watch_issue {
    my ($self, $id, $username) = @_;

    return $self->_client->watch_issue(id => $id, username => $username);
}

1;
