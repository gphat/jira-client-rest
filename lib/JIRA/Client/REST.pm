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
        $client->enable('Auth::Basic', username => 'cory.watson', password => '#.n883%P6VzEZg');
        return $client;
    }
);

has 'debug' => (
    is => 'rw',
    isa => 'Bool',
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
