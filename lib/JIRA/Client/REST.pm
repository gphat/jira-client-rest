package JIRA::Client::REST;
use Moose;

# ABSTRACT: JIRA REST Client

use Net::HTTP::Spore;

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
                        "method": "GET",
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
    isa => 'URI',
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

sub get_issue {
    my $self = shift;

    use Data::Dumper;
    print Dumper($self->_client->get_issue(@_));
}

1;
