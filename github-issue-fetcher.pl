use strict;
use warnings;
use utf8;

use HTTP::Tiny;
use URI;
use JSON::XS qw/decode_json/;
use Encode qw/encode_utf8/;
use Getopt::Long qw/:config posix_default no_ignore_case bundling auto_help/;

# See https://developer.github.com/v3/issues/#list-issues-for-a-repository
my %args = (
    state        => 'open',
    sort         => 'updated',
    direction    => 'asc',
    since        => '2015-12-31T15:00:00Z', # YYYY-MM-DDTHH:MM:SSZ
    assignee     => '', # Valid value:  *, none or username
    mentioned    => '',
    per_page     => 100,
    max_page     => 0, # 0 = unlimited, 2 = do not load any next pages
    log_debug    => 0,
);
if (my $e = $ENV{GITHUB_ACCESS_TOKEN}) {
    $args{access_token} = $e;
}
GetOptions(
    \%args, qw/
      target_repo|r=s
      state|st=s
      sort|so=s
      direction|d=s
      since|si=s
      assignee|a=s
      mentioned|me=s
      per_page|p=i
      access_token|t=s
      max_page|m=i
      log_debug
      /
) or die "[BUG] Failed to parse ARGV";

my $ua = HTTP::Tiny->new(timeout => 10);

sub build_init_uri() {
    my %query_parameters = map {
        length($args{$_}) ? ($_ => $args{$_}) : ()
    } (
        'state',
        'sort',
        'direction',
        'since',
        'assignee',
        'mentioned',
        'per_page',
        'access_token',
    );

    my $uri = URI->new('https://api.github.com');
    $uri->path(sprintf 'repos/%s/issues', $args{target_repo});
    $uri->query_form(%query_parameters);
    return $uri->as_string;
}

sub fetch_issues {
    my $uri = shift;

    my $response = $ua->get($uri);
    my $content  = $response->{content};
    my $headers  = $response->{headers};
    unless ($response->{success}) {
        die sprintf "Failed. content=%s, uri=%s\n",
            $content, $uri;
    }

    my @ret;
    my $content_json = decode_json $content;
    push @ret, @$content_json;

    if (my $link = $headers->{link}) {
        my @rel_strs = split ',', $link;
        my $next_url = _extract_next_url(@rel_strs);
        if ($next_url && $next_url !~ /page=$args{max_page}/) {
            my @next_ret = fetch_issues($next_url);
            _debug_print(encode_utf8
                "next: the number of fetched issues is " . scalar @next_ret . ", uri=$next_url\n"
            );
            push @ret, @next_ret;
        }
    }

    return @ret;
}

sub _extract_next_url(@) {
    my @raw_strs = @_;
    foreach my $str (@raw_strs) {
        my ($link_url, $rel) = split ';', $str;

        $link_url =~ s/^\s*//;
        $link_url =~ s/^<//;
        $link_url =~ s/>$//;

        $rel =~ m/rel="(next|last|first|prev)"/;
        $rel = $1;

        if ($rel eq 'next') {
            return $link_url;
        }
    }
    return '';
}

sub prettyPrint(@) {
    my @issues = @_;

    my @month_names = (
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug',
        'Sep', 'Oct', 'Nov', 'Dec'
    );

    my %issues_by_month = _group_by_month(@issues);
    foreach my $month (sort keys %issues_by_month) {
        my $month_name = $month_names[$month-1];
        print encode_utf8("\n# Activities in $month_name\n");

        my %month_groups;

        my $month_issues = $issues_by_month{$month};
        foreach my $issue (@$month_issues) {
            # output the link of each issue
            my $title    = $issue->{title};
            my $html_url = $issue->{html_url};
            my $text = sprintf "- [%s](%s)\n",
                $title, $html_url;
            print encode_utf8($text);

            # aggregate labels
            my $labels = $issue->{labels};
            foreach my $label (@$labels) {
                if (my $name = $label->{name}) {
                    $month_groups{label}->{$name} //= 0;
                    $month_groups{label}->{$name}++;
                }
            }
        }

        # output the result of aggregating
        if (my $lg = $month_groups{label}) {
            print encode_utf8("\n### Total number of label\n");
            foreach my $label ( sort { $lg->{$b} <=> $lg->{$a} } keys %$lg) {
                print encode_utf8(sprintf "- The number of %s is %d\n",
                    $label, $lg->{$label},
                );
            }
        }
    }
}

sub _group_by_month(@) {
    my @issues = @_;

    my %issues_by_month;
    foreach my $issue (@issues) {
        my $month = '';
        my $updated_at = $issue->{updated_at};
        if ($updated_at =~ /\d{4}-(\d{2})-.*/) {
            $month = $1;
        }
        die "[BUG] Failed to extract updated month" unless $month;

        $issues_by_month{$month} //= [];
        push @{$issues_by_month{$month}}, $issue;
    }
    return %issues_by_month;
}

sub _debug_print($) {
    my $text = shift;
    if ($args{log_debug}) {
        print $text;
    }
}

my $init_uri = build_init_uri();
my @issues = fetch_issues($init_uri);
_debug_print( encode_utf8
    "all: the number of fetched issues is " . scalar @issues ."\n"
);

prettyPrint(@issues);
