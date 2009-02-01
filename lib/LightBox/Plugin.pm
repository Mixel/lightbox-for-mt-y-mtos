package LightBox::Plugin;

use strict;

our $cache; #
our $old;


sub buildc {
  return 1 if (plugin()->get_config_value('LBway','system')  eq 'Man');
 my ($cb, %args) = @_;
 my $ref = $args{Content};
 my $content = $$ref;
 my $x;

 foreach  $x  ($content =~ m/(<a\s[a-z0-9="' )(.\/-_,]*href=["'][^<]+\.(jpg|png)["'][a-z0-9="' )(.\/-_,]*>)/mgi) {   
   if(length($x) > 5) # we skip the subpatterns 
   {
     my $y = $x;
     if ($y !~ m/rel\s*=\s*['"]/i) #skip it if rel is already set. -- for galleries
     {
       $y =~ s/<a/<a rel="lightbox"/i;
       $$ref =~ s/\Q$x\E/$y/mig;
      }
    } 
 }
 return 1;   
} 

sub lightboxscripts {
  my ($ctx, $args) = @_;
  return $cache unless(!$cache);
  my $blog = $ctx->stash('blog'); 
  my $out = '<script src="http://ajax.googleapis.com/ajax/libs/prototype/1.6.0.2/prototype.js" type="text/javascript"></script>';
  $out .= '<script src="http://ajax.googleapis.com/ajax/libs/scriptaculous/1.8.1/scriptaculous.js?load=effects,builder" type="text/javascript"></script>';
  $out .= '<script type="text/javascript" src="' . $blog->site_url .'/lightbox.js"></script>';
  $out .= '<link type="text/css" href="' . $blog->site_url . '/lightbox.css" rel="stylesheet" />'; 
  crea_plantilla('LightBoxJS','js.tmpl','lightbox.js',$blog); 
  crea_plantilla('LightBoxCSS','css.tmpl','lightbox.css',$blog);
  return $cache = $out;
}

sub crea_plantilla {
  my ($nombre,$tmpl,$archivo,$blog) = @_;
  use MT::Template;
  my $t =MT::Template->load({ blog_id=>$blog->id , name => $nombre});
  return 0 if (MT::Template->load({ blog_id=>$blog->id , name => $nombre})); #we exit if it already exists
  my $p = this();
  $t = $p->load_tmpl($tmpl);
  $t->name($nombre);
  $t->blog_id($blog->id);
  $t->type('index');
  $t->outfile($archivo);   
  $t->rebuild_me(1);  
  $t->save() or die $tmpl->errstr;
}

sub init_app{
  #if globally disabled, then no hook needed
  return 1 if (plugin()->get_config_value('LBway','system')  eq 'Auto');

  no warnings 'redefine';
  no strict 'refs';
  require MT::Asset::Image;
#   the hook
  if ($old = MT::Asset::Image->can('as_html')) {  
    *MT::Asset::Image::as_html = sub{          
      my ($texto) = $old->(@_);
      my $asset = shift;  
      my $scope = "blog:" . $asset->blog->id;
#     if blog disabled then return the text W/o modifications       
      $asset = MT::Util::encode_html( $asset->label);
      $texto =~ s/<a/<a rel="lightbox" title="$asset"/;
      return $texto;
    };     
  }
}

sub plugin {
  return MT->component("LightBox");
}

#        MT->log({            
#          message => 'debug',
#          class => 'system',
#          level => MT::Log::INFO(), 
#        });

#  <strong>Automática:</strong> LightBox se activara con cualquier link que apunte a una imagen exepto en aquellos que contienen la equiqueta rel.<br /> 
#                 <strong>Manual:</strong>     LightBox solo se activara en las imagenes que sean agregadas apartir de este momento.</br >
#                 <strong>Ambos:</strong>      La activación sera de las dos formas.



1;