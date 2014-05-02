package MyCGI;
use Exporter;
use CGI;
use Benchmark;
use Time::HiRes qw(gettimeofday tv_interval);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);
our @EXPORT      = qw(debug info error);
our @EXPORT_OK   = qw(encoding mime_type jsonp_header jsonp_footer time_this);
our %EXPORT_TAGS = ( DEFAULT => [qw(&func1)],
                     Both    => [qw(&func1 &func2)]);

our ($BM1, $T01);
our $LOG_LEVEL       = 0; # 0-debug, 1-info, 2-warn
our $MODE_PRODUCTION = 0;
our $MODE_TESTING    = 0;
our $MODE_DEBUG      = 0;

sub init_loglevel {
  $BM1 = Benchmark->new() unless defined $BM1;
  $T01 = [gettimeofday] unless defined $T01;

  my $q = CGI->new();
  my $mode = $q->param('mode') || "";
  $MODE_PRODUCTION = ( $q->server_port eq "80" and defined $ENV{GATEWAY_INTERFACE} ) ? 1 : 0;
  $MODE_TESTING    = ( defined $ENV{GATEWAY_INTERFACE} ) ? 1 : 0;

  $MODE_PRODUCTION = 1 if $mode eq q(production);
  $MODE_DEBUG      = 1 if $mode eq q(debug);
  $MODE_DEBUG      = 1 unless $q->server_port eq "80" or $q->server_port eq "8080";
  1;
}

sub encoding {
  my $encoding = shift or return 'utf-8';

  if ( $encoding =~ m/euc-?kr|cp949/i ) { $encoding = 'cp949'; }
  else { $encoding = 'utf-8'; }

  binmode STDOUT, ":encoding(UTF-8)" if $encoding eq 'utf-8';
  binmode STDOUT, ":encoding(CP949)" if $encoding eq 'cp949';
  return $encoding;
}

sub mime_type {
  my ($suffix, $callback) = (shift || q(.json), shift);
  return q(text/plain)              if $suffix eq ".txt";
  return q(text/html)               if $suffix eq ".html";
  return q(application/javascript)  if $suffix eq ".json" and $callback;

  # http://en.wikipedia.org/wiki/JSON#MIME_type
  return q(application/json)        if $suffix eq ".json";
  return q(text/plain);
}

sub jsonp_header {
  my ($callback) = @_;
  return <<END if $callback;
if (typeof $callback === "function") $callback(
END
  return "";
}
  
sub jsonp_footer {
  my ($callback) = @_;
  return <<END if $callback;
);
END
  return "";
}

sub debug {
  return if $MODE_PRODUCTION or $MODE_TESTING or $LOG_LEVEL > 0;
  info(@_); 
}
  
sub info {
  return if $MODE_PRODUCTION or $MODE_TESTING or $LOG_LEVEL > 1;
  
  my ($message) = @_;
  my ($BM2, $T02) = (new Benchmark, [gettimeofday]);
  my $elapsed   = sprintf("%1.6f", tv_interval($T01, $T02));
  my $benchmark = timestr(timediff($BM2, $BM1));
  warn "$elapsed secs: $message\n";
}
  
sub time_this {
  my ($message) = @_;
  my ($BM2, $T02) = (new Benchmark, [gettimeofday]);
  my $elapsed   = sprintf("%1.6f", tv_interval($T01, $T02));
  my $benchmark = timestr(timediff($BM2, $BM1));
  return "$elapsed secs($benchmark) $message\n";
}

sub error {
  my $status = "400 Bad Request";
  my $q = CGI->new();
  print $q->header(-status=>$status, -charset=>encoding(), -type=>'text/plain');

  print map { $_, "\n"; } @_;

  if ( $ENV{MOD_PERL} ) { # mod_perl ON
    my $r = CGI->new->r;
    $r->status(400);
    $r->rflush; # force sending headers (with headers set by CGI)
    $r->status(200); # tell Apache that everything was ok, dont send error doc.
  }

  exit;
}

1;

