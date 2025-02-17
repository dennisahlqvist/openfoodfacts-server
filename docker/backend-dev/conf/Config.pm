# This file is part of Product Opener.
#
# Product Opener
# Copyright (C) 2011-2020 Association Open Food Facts
# Contact: contact@openfoodfacts.org
# Address: 21 rue des Iles, 94100 Saint-Maur des Fossés, France
#
# Product Opener is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

package ProductOpener::Config;

use utf8;
use Modern::Perl '2017';
use Exporter    qw< import >;

BEGIN
{
	use vars       qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	@EXPORT = qw();
	@EXPORT_OK = qw(
		%string_normalization_for_lang
		%admins
		%moderators

		$server_domain
		@ssl_subdomains
		$data_root
		$www_root
		$geolite2_path
		$reference_timezone
		$contact_email
		$admin_email

		$facebook_app_id
		$facebook_app_secret

		$robotoff_url

		$mongodb
		$mongodb_host

		$memd_servers

		$google_analytics

		$thumb_size
		$crop_size
		$small_size
		$display_size
		$zoom_size

		$page_size

		%options
		%server_options

		@product_fields
		@product_other_fields
		@display_fields
		@display_other_fields
		@drilldown_fields
		@taxonomy_fields
		@export_fields

		%tesseract_ocr_available_languages

		%weblink_templates

		@edit_rules

	);
	%EXPORT_TAGS = (all => [@EXPORT_OK]);
}
use vars @EXPORT_OK ; # no 'my' keyword for these

use ProductOpener::Config2;

# define the normalization applied to change a string to a tag id (in particular for taxonomies)
# tag ids are also used in URLs.

# unaccent:
# - useful when accents are sometimes ommited (e.g. in French accents are often not present on capital letters),
# either in print, or when typed by users.
# - dangerous if different words (in the same context like ingredients or category names) have the same unaccented form
# lowercase:
# - useful when the same word appears in lowercase, with a first capital letter, or in all caps.

%string_normalization_for_lang = (
	# no_language is used for strings that are not in a specific language (e.g. user names)
	no_language => {
		unaccent => 1,
		lowercase => 1,
	},
	# default is used for languages that do not have specified values
	default => {
		unaccent => 0,
		lowercase => 1,
	},
	# German umlauts should not be converted (e.g. ä -> ae) as there are many conflicts
	de => {
		unaccent => 0,
		lowercase => 1,
	},
	# French has very few actual conflicts caused by unaccenting (one counter example is "pâtes" and "pâtés")
	# Accents or often not present in capital letters (beginning of word, or in all caps text).
	fr => {
		unaccent => 1,
		lowercase => 1,
	},
	# Same for Spanish, Italian and Portuguese
	es => {
		unaccent => 1,
		lowercase => 1,
	},
	it => {
		unaccent => 1,
		lowercase => 1,
	},
	pt => {
		unaccent => 1,
		lowercase => 1,
	},
	# English has very few accented words, and they are very often not accented by users or in ingredients lists etc.
	en => {
		unaccent => 1,
		lowercase => 1,
	},
);

%admins = map { $_ => 1 } qw(
admin
);

%moderators = map { $_ => 1 } qw(
moderator
);

@edit_rules = (

{
	name => "Edit Rules Testing",
	conditions => [
		["user_id", "editrulestest"],
	],
	actions => [
		["ignore_if_existing_ingredients_text_fr"],
		["warn_if_0_nutriment_fruits-vegetables-nuts"],
		["warn_if_greater_nutriment_fruits-vegetables-nuts", 0],
		["ignore_if_regexp_match_packaging", '\b(artikel|produit|producto|produkt|produkte)\b'],
	],
	notifications => [ qw (
		slack_channel_edit-alert
	)],
},

{
	name => "Yuka",
	conditions => [
		["user_id", "kiliweb"],
	],
	actions => [
		["warn_if_existing_brands"],
		["ignore_if_existing_ingredients_text"],
		["ignore_if_existing_ingredients_text_fr"],
		["ignore_if_0_nutriment_fruits-vegetables-nuts"],
		["ignore_if_greater_nutriment_fruits-vegetables-nuts", 0],
	],
	notifications => [ qw (
		slack_channel_edit-alert
	)],
},

{
	name => "Date Limite",
	conditions => [
		["user_id", "date-limite-app"],
	],
	actions => [
		["ignore_if_regexp_match_packaging", '\b(artikel|produit|producto|produkt|produkte)\b'],
	],
	notifications => [ qw (
		slack_channel_edit-alert
	)],
},

{
	name => "Fleury Michon",
	conditions => [
		["user_id_not", "fleury-michon"],
		["in_brands_tags", "fleury-michon"],
	],
	actions => [
		["warn"]
	],
	notifications => [ qw (
                slack_channel_edit-alert
        )],
},

);


# server constants
$server_domain = $ProductOpener::Config2::server_domain;
@ssl_subdomains = @ProductOpener::Config2::ssl_subdomains;
$mongodb = $ProductOpener::Config2::mongodb;
$mongodb_host = $ProductOpener::Config2::mongodb_host;
$memd_servers = $ProductOpener::Config2::memd_servers;

# server paths
$www_root = $ProductOpener::Config2::www_root;
$data_root = $ProductOpener::Config2::data_root;

$geolite2_path = $ProductOpener::Config2::geolite2_path;

$facebook_app_id = $ProductOpener::Config2::facebook_app_id;
$facebook_app_secret = $ProductOpener::Config2::facebook_app_secret;

$robotoff_url = $ProductOpener::Config2::robotoff_url;
%server_options = %ProductOpener::Config2::server_options;

$reference_timezone = 'Europe/Paris';

$contact_email = 'contact@' . $server_domain;
$admin_email = 'admin@' . $server_domain;

$thumb_size = 100;
$crop_size = 400;
$small_size = 200;
$display_size = 400;
$zoom_size = 800;

$page_size = 20;


$google_analytics = '';

my @icons = (
	{ "platform" => "ios", "sizes" => "57x57", "src" => "https://static.$server_domain/images/favicon/apple-touch-icon-57x57.png" },
	{ "platform" => "ios", "sizes" => "60x60", "src" => "https://static.$server_domain/images/favicon/apple-touch-icon-60x60.png" },
	{ "platform" => "ios", "sizes" => "72x72", "src" => "https://static.$server_domain/images/favicon/apple-touch-icon-72x72.png" },
	{ "platform" => "ios", "sizes" => "76x76", "src" => "https://static.$server_domain/images/favicon/apple-touch-icon-76x76.png" },
	{ "platform" => "ios", "sizes" => "114x114", "src" => "https://static.$server_domain/images/favicon/apple-touch-icon-114x114.png" },
	{ "platform" => "ios", "sizes" => "120x120", "src" => "https://static.$server_domain/images/favicon/apple-touch-icon-120x120.png" },
	{ "platform" => "ios", "sizes" => "144x144", "src" => "https://static.$server_domain/images/favicon/apple-touch-icon-144x144.png" },
	{ "platform" => "ios", "sizes" => "152x152", "src" => "https://static.$server_domain/images/favicon/apple-touch-icon-152x152.png" },
	{ "platform" => "ios", "sizes" => "180x180", "src" => "https://static.$server_domain/images/favicon/apple-touch-icon-180x180.png" },
	{ "type" => "image/png", "src" => "https://static.$server_domain/images/favicon/favicon-32x32.png", "sizes" => "32x32" },
	{ "type" => "image/png", "src" => "https://static.$server_domain/images/favicon/android-chrome-192x192.png", "sizes" => "192x192" },
	{ "type" => "image/png", "src" => "https://static.$server_domain/images/favicon/favicon-96x96.png", "sizes" => "96x96" },
	{ "type" => "image/png", "src" => "https://static.$server_domain/images/favicon/favicon-16x16.png", "sizes" => "16x16" },
);

my @related_applications = (
	{ 'platform' => 'play', 'id' => 'org.openfoodfacts.scanner', 'url' => 'https://play.google.com/store/apps/details?id=org.openfoodfacts.scanner' },
	{ 'platform' => 'ios', 'id' => 'id588797948', 'url' => 'https://apps.apple.com/app/id588797948' },
);

my $manifest;
$manifest->{icons} = \@icons;
$manifest->{related_applications} = \@related_applications;
$manifest->{theme_color} = '#ffffff';
$manifest->{background_color} = '#ffffff';
$options{manifest} = $manifest;

$options{favicons} = <<HTML
<link rel="manifest" href="/cgi/manifest.pl">
<link rel="mask-icon" href="/images/favicon/safari-pinned-tab.svg" color="#5bbad5">
<link rel="shortcut icon" href="/images/favicon/favicon.ico">
<meta name="msapplication-TileColor" content="#da532c">
<meta name="msapplication-TileImage" content="/images/favicon/mstile-144x144.png">
<meta name="msapplication-config" content="/images/favicon/browserconfig.xml">
HTML
;

$options{opensearch_image} = <<XML
<Image width="16" height="16" type="image/x-icon">https://static.$server_domain/images/favicon/favicon.ico</Image>
XML
;

# fields for which we will load taxonomies

@taxonomy_fields = qw(states countries languages labels categories additives additives_classes
vitamins minerals amino_acids nucleotides other_nutritional_substances allergens traces
nutrient_levels misc ingredients ingredients_analysis nova_groups);


# fields in product edit form, above ingredients and nutrition facts

@product_fields = qw(quantity packaging brands categories labels origins manufacturing_places
 emb_codes link expiration_date purchase_places stores countries  );

# fields currently not shown in the default edit form, can be used in imports or advanced edit forms

@product_other_fields = qw(
	producer_product_id
	producer_version_id
	net_weight_value
	net_weight_unit
	drained_weight_value
	drained_weight_unit
	volume_value
	volume_unit
	other_information
	conservation_conditions
	recycling_instructions_to_recycle
	recycling_instructions_to_discard
	nutrition_grade_fr_producer
	recipe_idea origin
	customer_service
	producer
	preparation
	warning
	data_sources
);


# fields shown on product page
# do not show purchase_places

@display_fields = qw(
	generic_name
	quantity
	packaging
	brands
	categories
	labels
	origin
	origins
	producer
	manufacturing_places
	emb_codes
	link stores
	countries
);

# fields displayed in a new section after the nutrition facts

@display_other_fields = qw(
	other_information
	preparation
	recipe_idea
	warning
	conservation_conditions
	recycling_instructions_to_recycle
	recycling_instructions_to_discard
	customer_service
);


# fields for drilldown facet navigation

@drilldown_fields = qw(
	brands
	categories
	labels
	packaging
	origins
	manufacturing_places
	emb_codes
	ingredients
	additives
	vitamins
	minerals
	amino_acids
	nucleotides
	other_nutritional_substances
	allergens
	traces
	nova_groups
	nutrition_grades
	misc
	languages
	users
	states
	data_sources
	entry_dates
	last_edit_dates
	last_check_dates
);


@export_fields = qw(
	code
	creator
	created_t
	last_modified_t
	product_name
	generic_name
	quantity
	packaging
	brands
	categories
	origins
	manufacturing_places
	labels
	emb_codes
	cities
	purchase_places
	stores
	countries
	ingredients_text
	allergens
	traces
	serving_size
	serving_quantity
	no_nutriments
	additives_n
	additives
	ingredients_from_palm_oil_n
	ingredients_from_palm_oil
	ingredients_that_may_be_from_palm_oil_n
	ingredients_that_may_be_from_palm_oil
	nutrition_grade_fr
	nova_group
	pnns_groups_1
	pnns_groups_2
	states
);

$options{import_export_fields_groups} = [
	["identification", ["code", "producer_product_id", "producer_version_id", "lc", "product_name", "generic_name",
		"quantity_value_unit", "net_weight_value_unit", "drained_weight_value_unit", "volume_value_unit", "packaging",
		"brands", "categories", "categories_specific", "labels", "labels_specific", "countries", "stores"]
	],
	["origins", ["origins", "origin", "manufacturing_places", "producer", "emb_codes"]
	],
	["ingredients", ["ingredients_text", "allergens", "traces"]
	],
	["nutrition"],
	["nutrition_other"],
	["other", ["conservation_conditions", "warning", "preparation", "recipe_idea", "recycling_instructions_to_recycle", "recycling_instructions_to_discard", "customer_service", "link"]
	],
];

# for ingredients OCR, we use tesseract-ocr
# on debian, dictionaries are in /usr/share/tesseract-ocr/tessdata
# %tesseract_ocr_available_languages provides mapping between OFF 2 letter language codes
# and the available tesseract dictionaries
# Tesseract uses 3-character ISO 639-2 language codes
# all dictionaries: apt-get install tesseract-ocr-all

%tesseract_ocr_available_languages = (
	en => "eng",
	de => "deu",
	es => "spa",
	fr => "fra",
	it => "ita",
#	ja => "jpn", # not available with tesseract 2
	nl => "nld",
);

# weblink definitions for known tags, ie. wikidata:en:Q123 => https://www.wikidata.org/wiki/Q123

%weblink_templates = (

	'wikidata:en' => { href => 'https://www.wikidata.org/wiki/%s', text => 'Wikidata', parse => sub
	{
		my ($url) = @_;
		if ($url =~ /^https?:\/\/www.wikidata.org\/wiki\/(Q\d+)$/) {
			return $1
		}

		return;
	} },

);

1;
