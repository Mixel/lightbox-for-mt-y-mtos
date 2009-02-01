package LightBox::L10N::en_us;

use strict;

use base 'LightBox::L10N';
use vars qw( %Lexicon );
%Lexicon = (
    '__desc__' => 'The way LightBox would interact with your blog.<br />
           Automatic: LightBox will be attached to any link pointing an image except those containig a rel tag.<br />
           Manual:    LightBox rel tag will be added to images when they are embeded into entries.<br />
           Both:      Both of them',
);

1;
