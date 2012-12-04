package TwitterPersons;
use utf8;
use strict;
use warnings;
use WWW::Mechanize;
use XML::Simple;
use URI::Escape;
use lib qw( /home/toshi/perl/lib );
use Encode;
use feature 'say';
use Storable qw(nstore retrieve);

sub new {
	my $proto = shift;
	my $class = ref $proto || $proto;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub named {
	my $self = shift;
	my $screen_name = shift;
	$self->{screen_name} = $screen_name;
	if ( -e  "./dat/${screen_name}.dat") {
		$self->_reserialize;
	}else{
		$self->init;
	}
	return $self;
}

sub renew {
	my $self = shift;
	$self->init;
	return $self;
}

sub init {
	my $self = shift;
	$self->_get_prof;
	$self->_has_connection;
	$self->_get_mutual_users;
	$self->_serialize;
	return $self;
}

sub _serialize {
	my $self = shift;
	my $screen_name = $self->screen_name;
	my $serialize = {
		screen_name => $self->{screen_name},
		prof				=> $self->{prof},
		friends			=> $self->{friends},
		followers		=> $self->{followers},
		mutuals			=> $self->{mutuals},
		following		=> $self->{following},
		followed		=> $self->{followed},
	};
	unless ( -d './dat'){
		mkdir 'dat';
	}
	my $data_file = "./dat/${screen_name}.dat";
	say "store to $data_file";
	nstore $serialize, $data_file;
	return;
}

sub _reserialize {
	my $self = shift;
	my $screen_name = $self->screen_name;
	my $data_file = "./dat/${screen_name}.dat";
	say "retirive from $data_file";
	my $serialize2 = retrieve $data_file;

	$self->{screen_name}	= $serialize2->{screen_name};
	$self->{prof}					= $serialize2->{prof};
	$self->{friends}			= $serialize2->{friends};
	$self->{followers}		= $serialize2->{followers};
	$self->{mutuals}			= $serialize2->{mutuals};
	$self->{following}		= $serialize2->{following};
	$self->{followed}			=	$serialize2->{followed};
	return $self;
}

sub _has_connection {
	my $self = shift;
	my $screen_name = $self->{screen_name};
	my @friends = _get_users($screen_name, 'friends');
	my @followers = _get_users($screen_name, 'followers');
	$self->{friends} = \@friends;
	$self->{followers} = \@followers;
	return $self;
}		 

sub screen_name {
	my $self =shift;
	return $self->{screen_name};
}

sub prof {
	my $self = shift;
	return $self->{prof};
}

sub friends {
	my $self =shift;
	return $self->{friends};
}

sub followers {
	my $self =shift;
	return $self->{followers};
}

sub mutuals {
	my $self =shift;
	return $self->{mutuals};
}

sub following {
	my $self =shift;
	return $self->{following};
}

sub followed {
	my $self =shift;
	return $self->{followed};
}

sub _get_prof {
	my $self = shift;
	my $mech = WWW::Mechanize->new;
	my $api_url = 'http://api.twitter.com/1/users/lookup.xml?screen_name=';
	my $screen_name = $self->{screen_name};
	say "getting ${screen_name}'s profile";
	my $url = $api_url . $screen_name;
	$mech->get($url);

	my $content = $mech->content;

	$content = uri_unescape($content);
	$content = decode('utf-8',$content);
	my $xml = XMLin($content);

	$self->{prof} = $xml->{user};
	say "done";
	return $self;
}

sub _get_users {
	my $api_url = 'http://api.twitter.com/1/statuses/';
	my $screen_name = shift;
	my $method = shift;
	my $cursor = -1;
	my @users;
	my $n = 0;
	my $mech = WWW::Mechanize->new;

	say "going get $method";
	while( $cursor != 0) {
		say "wait a while";
		my $url = $api_url . $method . '/' .$screen_name . '.xml?cursor=' . $cursor;
		$mech->get($url);
		my $content = $mech->content;
		say $mech->uri;
		my $xml = XMLin($content);
 		my $xml_users = $xml->{users}->{user};

		if (ref $xml_users eq 'HASH'){
			for my  $value (values %$xml_users){
				$users[$n] = {
					'screen_name'			 => $value->{screen_name},
					'followers_count'	 => $value->{followers_count},
					'friends_count' 	 => $value->{friends_count},
				};
			++$n;
			}
		}else{
			for my  $value (@$xml_users){
				$users[$n] = {
					'screen_name'			 => $value->{screen_name},
					'followers_count'	 => $value->{followers_count},
					'friends_count' 	 => $value->{friends_count},
				};
			++$n;
			}
		}
		$cursor = $xml->{next_cursor};
	}
	say "done";
	return @users;
}


sub _get_mutual_users {
	my $self = shift;
	my $friends = $self->friends;
	my $followers = $self->followers;
	my @mutuals;
	my @following;
	my @followed;

	say "search mutuals and following";
	sleep 2;
	for my $friend (@$friends){
		my $friend_name = $friend->{screen_name};
		say $friend_name;
		my $flag = 0;
		for my $follower (@$followers){
			my $follower_name = $follower->{screen_name};
			if ($friend_name eq $follower_name){
				say "mutual : $friend_name : $follower_name";
				push (@mutuals ,$friend);
				$flag = 1;
				last;
			}else{
				next;
			}
		}
		next if $flag;
		say "following : $friend_name";
		push (@following, $friend);
#		sleep 1;
	}


	say "check end following"; 
	sleep 2;
	for my $follower (@$followers){
		my $follower_name = $follower->{screen_name};
		say $follower_name;
		my $flag = 0;
		for my $friend (@$friends){
			my $friend_name = $friend->{screen_name};
			if ($friend_name eq $follower_name){
				say "mutual : $follower_name : $friend_name ";
#				push (@mutuals ,$follower);
				$flag =1;
				last;
			}else{
				next;
			}
		}
		next if $flag;
		say "followed by : $follower_name";
		push (@followed, $follower);
#		sleep 1;
	}

	$self->{mutuals} = \@mutuals;
	$self->{following} = \@following;
	$self->{followed} = \@followed;

	say "done";
	sleep 3;
	return $self;
}		
1;
