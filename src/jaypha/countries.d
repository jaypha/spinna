module jaypha.countries;

import std.exception : assumeUnique;

enum Country : string {
  AD = "ad",
  AE = "ae",
  AF = "af",
  AG = "ag",
  AI = "ai",
  AL = "al",
  AM = "am",
  AO = "ao",
  AQ = "aq",
  AR = "ar",
  AS = "as",
  AT = "at",
  AU = "au",
  AW = "aw",
  AX = "ax",
  AZ = "az",
  BA = "ba",
  BB = "bb",
  BD = "bd",
  BE = "be",
  BF = "bf",
  BG = "bg",
  BH = "bh",
  BI = "bi",
  BJ = "bj",
  BL = "bl",
  BM = "bm",
  BN = "bn",
  BO = "bo",
  BQ = "bq",
  BR = "br",
  BS = "bs",
  BT = "bt",
  BV = "bv",
  BW = "bw",
  BY = "by",
  BZ = "bz",
  CA = "ca",
  CC = "cc",
  CD = "cd",
  CF = "cf",
  CG = "cg",
  CH = "ch",
  CI = "ci",
  CK = "ck",
  CL = "cl",
  CM = "cm",
  CN = "cn",
  CO = "co",
  CR = "cr",
  CU = "cu",
  CV = "cv",
  CW = "cw",
  CX = "cx",
  CY = "cy",
  CZ = "cz",
  DE = "de",
  DJ = "dj",
  DK = "dk",
  DM = "dm",
  DO = "do",
  DZ = "dz",
  EC = "ec",
  EE = "ee",
  EG = "eg",
  EH = "eh",
  ER = "er",
  ES = "es",
  ET = "et",
  FI = "fi",
  FJ = "fj",
  FK = "fk",
  FM = "fm",
  FO = "fo",
  FR = "fr",
  GA = "ga",
  GB = "gb",
  GD = "gd",
  GE = "ge",
  GF = "gf",
  GG = "gg",
  GH = "gh",
  GI = "gi",
  GL = "gl",
  GM = "gm",
  GN = "gn",
  GP = "gp",
  GQ = "gq",
  GR = "gr",
  GS = "gs",
  GT = "gt",
  GU = "gu",
  GW = "gw",
  GY = "gy",
  HK = "hk",
  HM = "hm",
  HN = "hn",
  HR = "hr",
  HT = "ht",
  HU = "hu",
  ID = "id",
  IE = "ie",
  IL = "il",
  IM = "im",
  IN = "in",
  IO = "io",
  IQ = "iq",
  IR = "ir",
  IS = "is",
  IT = "it",
  JE = "je",
  JM = "jm",
  JO = "jo",
  JP = "jp",
  KE = "ke",
  KG = "kg",
  KH = "kh",
  KI = "ki",
  KM = "km",
  KN = "kn",
  KP = "kp",
  KR = "kr",
  KW = "kw",
  KY = "ky",
  KZ = "kz",
  LA = "la",
  LB = "lb",
  LC = "lc",
  LI = "li",
  LK = "lk",
  LR = "lr",
  LS = "ls",
  LT = "lt",
  LU = "lu",
  LV = "lv",
  LY = "ly",
  MA = "ma",
  MC = "mc",
  MD = "md",
  ME = "me",
  MF = "mf",
  MG = "mg",
  MH = "mh",
  MK = "mk",
  ML = "ml",
  MM = "mm",
  MN = "mn",
  MO = "mo",
  MP = "mp",
  MQ = "mq",
  MR = "mr",
  MS = "ms",
  MT = "mt",
  MU = "mu",
  MV = "mv",
  MW = "mw",
  MX = "mx",
  MY = "my",
  MZ = "mz",
  NA = "na",
  NC = "nc",
  NE = "ne",
  NF = "nf",
  NG = "ng",
  NI = "ni",
  NL = "nl",
  NO = "no",
  NP = "np",
  NR = "nr",
  NU = "nu",
  NZ = "nz",
  OM = "om",
  PA = "pa",
  PE = "pe",
  PF = "pf",
  PG = "pg",
  PH = "ph",
  PK = "pk",
  PL = "pl",
  PM = "pm",
  PN = "pn",
  PR = "pr",
  PS = "ps",
  PT = "pt",
  PW = "pw",
  PY = "py",
  QA = "qa",
  RE = "re",
  RO = "ro",
  RS = "rs",
  RU = "ru",
  RW = "rw",
  SA = "sa",
  SB = "sb",
  SC = "sc",
  SD = "sd",
  SE = "se",
  SG = "sg",
  SH = "sh",
  SI = "si",
  SJ = "sj",
  SK = "sk",
  SL = "sl",
  SM = "sm",
  SN = "sn",
  SO = "so",
  SR = "sr",
  SS = "ss",
  ST = "st",
  SV = "sv",
  SX = "sx",
  SY = "sy",
  SZ = "sz",
  TC = "tc",
  TD = "td",
  TF = "tf",
  TG = "tg",
  TH = "th",
  TJ = "tj",
  TK = "tk",
  TL = "tl",
  TM = "tm",
  TN = "tn",
  TO = "to",
  TR = "tr",
  TT = "tt",
  TV = "tv",
  TW = "tw",
  TZ = "tz",
  UA = "ua",
  UG = "ug",
  UM = "um",
  US = "us",
  UY = "uy",
  UZ = "uz",
  VA = "va",
  VC = "vc",
  VE = "ve",
  VG = "vg",
  VI = "vi",
  VN = "vn",
  VU = "vu",
  WF = "wf",
  WS = "ws",
  YE = "ye",
  YT = "yt",
  ZA = "za",
  ZM = "zm",
  ZW = "zw",
};

string[Country] country_labels;

static this()
{
  country_labels= [
  Country.AD : "Andorra",
  Country.AE : "United Arab Emirates (the)",
  Country.AF : "Afghanistan",
  Country.AG : "Antigua and Barbuda",
  Country.AI : "Anguilla",
  Country.AL : "Albania",
  Country.AM : "Armenia",
  Country.AO : "Angola",
  Country.AQ : "Antarctica",
  Country.AR : "Argentina",
  Country.AS : "American Samoa",
  Country.AT : "Austria",
  Country.AU : "Australia",
  Country.AW : "Aruba",
  Country.AX : "Åland Islands",
  Country.AZ : "Azerbaijan",
  Country.BA : "Bosnia and Herzegovina",
  Country.BB : "Barbados",
  Country.BD : "Bangladesh",
  Country.BE : "Belgium",
  Country.BF : "Burkina Faso",
  Country.BG : "Bulgaria",
  Country.BH : "Bahrain",
  Country.BI : "Burundi",
  Country.BJ : "Benin",
  Country.BL : "Saint Barthélemy",
  Country.BM : "Bermuda",
  Country.BN : "Brunei Darussalam",
  Country.BO : "Bolivia, Plurinational State of",
  Country.BQ : "Bonaire, Sint Eustatius and Saba",
  Country.BR : "Brazil",
  Country.BS : "Bahamas (the)",
  Country.BT : "Bhutan",
  Country.BV : "Bouvet Island",
  Country.BW : "Botswana",
  Country.BY : "Belarus",
  Country.BZ : "Belize",
  Country.CA : "Canada",
  Country.CC : "Cocos (Keeling) Islands (the)",
  Country.CD : "Congo (the Democratic Republic of the)",
  Country.CF : "Central African Republic (the)",
  Country.CG : "Congo",
  Country.CH : "Switzerland",
  Country.CI : "Côte d'Ivoire",
  Country.CK : "Cook Islands (the)",
  Country.CL : "Chile",
  Country.CM : "Cameroon",
  Country.CN : "China",
  Country.CO : "Colombia",
  Country.CR : "Costa Rica",
  Country.CU : "Cuba",
  Country.CV : "Cape Verde",
  Country.CW : "Curaçao",
  Country.CX : "Christmas Island",
  Country.CY : "Cyprus",
  Country.CZ : "Czech Republic (the)",
  Country.DE : "Germany",
  Country.DJ : "Djibouti",
  Country.DK : "Denmark",
  Country.DM : "Dominica",
  Country.DO : "Dominican Republic (the)",
  Country.DZ : "Algeria",
  Country.EC : "Ecuador",
  Country.EE : "Estonia",
  Country.EG : "Egypt",
  Country.EH : "Western Sahara*",
  Country.ER : "Eritrea",
  Country.ES : "Spain",
  Country.ET : "Ethiopia",
  Country.FI : "Finland",
  Country.FJ : "Fiji",
  Country.FK : "Falkland Islands (the) [Malvinas]",
  Country.FM : "Micronesia (the Federated States of)",
  Country.FO : "Faroe Islands (the)",
  Country.FR : "France",
  Country.GA : "Gabon",
  Country.GB : "United Kingdom (the)",
  Country.GD : "Grenada",
  Country.GE : "Georgia",
  Country.GF : "French Guiana",
  Country.GG : "Guernsey",
  Country.GH : "Ghana",
  Country.GI : "Gibraltar",
  Country.GL : "Greenland",
  Country.GM : "Gambia (The)",
  Country.GN : "Guinea",
  Country.GP : "Guadeloupe",
  Country.GQ : "Equatorial Guinea",
  Country.GR : "Greece",
  Country.GS : "South Georgia and the South Sandwich Islands",
  Country.GT : "Guatemala",
  Country.GU : "Guam",
  Country.GW : "Guinea-Bissau",
  Country.GY : "Guyana",
  Country.HK : "Hong Kong",
  Country.HM : "Heard Island and McDonald Islands",
  Country.HN : "Honduras",
  Country.HR : "Croatia",
  Country.HT : "Haiti",
  Country.HU : "Hungary",
  Country.ID : "Indonesia",
  Country.IE : "Ireland",
  Country.IL : "Israel",
  Country.IM : "Isle of Man",
  Country.IN : "India",
  Country.IO : "British Indian Ocean Territory (the)",
  Country.IQ : "Iraq",
  Country.IR : "Iran (the Islamic Republic of)",
  Country.IS : "Iceland",
  Country.IT : "Italy",
  Country.JE : "Jersey",
  Country.JM : "Jamaica",
  Country.JO : "Jordan",
  Country.JP : "Japan",
  Country.KE : "Kenya",
  Country.KG : "Kyrgyzstan",
  Country.KH : "Cambodia",
  Country.KI : "Kiribati",
  Country.KM : "Comoros",
  Country.KN : "Saint Kitts and Nevis",
  Country.KP : "Korea (the Democratic People's Republic of)",
  Country.KR : "Korea (the Republic of)",
  Country.KW : "Kuwait",
  Country.KY : "Cayman Islands (the)",
  Country.KZ : "Kazakhstan",
  Country.LA : "Lao People's Democratic Republic (the)",
  Country.LB : "Lebanon",
  Country.LC : "Saint Lucia",
  Country.LI : "Liechtenstein",
  Country.LK : "Sri Lanka",
  Country.LR : "Liberia",
  Country.LS : "Lesotho",
  Country.LT : "Lithuania",
  Country.LU : "Luxembourg",
  Country.LV : "Latvia",
  Country.LY : "Libya",
  Country.MA : "Morocco",
  Country.MC : "Monaco",
  Country.MD : "Moldova (the Republic of)",
  Country.ME : "Montenegro",
  Country.MF : "Saint Martin (French part)",
  Country.MG : "Madagascar",
  Country.MH : "Marshall Islands (the)",
  Country.MK : "Macedonia (the former Yugoslav Republic of)",
  Country.ML : "Mali",
  Country.MM : "Myanmar",
  Country.MN : "Mongolia",
  Country.MO : "Macao",
  Country.MP : "Northern Mariana Islands (the)",
  Country.MQ : "Martinique",
  Country.MR : "Mauritania",
  Country.MS : "Montserrat",
  Country.MT : "Malta",
  Country.MU : "Mauritius",
  Country.MV : "Maldives",
  Country.MW : "Malawi",
  Country.MX : "Mexico",
  Country.MY : "Malaysia",
  Country.MZ : "Mozambique",
  Country.NA : "Namibia",
  Country.NC : "New Caledonia",
  Country.NE : "Niger (the)",
  Country.NF : "Norfolk Island",
  Country.NG : "Nigeria",
  Country.NI : "Nicaragua",
  Country.NL : "Netherlands (the)",
  Country.NO : "Norway",
  Country.NP : "Nepal",
  Country.NR : "Nauru",
  Country.NU : "Niue",
  Country.NZ : "New Zealand",
  Country.OM : "Oman",
  Country.PA : "Panama",
  Country.PE : "Peru",
  Country.PF : "French Polynesia",
  Country.PG : "Papua New Guinea",
  Country.PH : "Philippines (the)",
  Country.PK : "Pakistan",
  Country.PL : "Poland",
  Country.PM : "Saint Pierre and Miquelon",
  Country.PN : "Pitcairn",
  Country.PR : "Puerto Rico",
  Country.PS : "Palestine, State of",
  Country.PT : "Portugal",
  Country.PW : "Palau",
  Country.PY : "Paraguay",
  Country.QA : "Qatar",
  Country.RE : "Réunion",
  Country.RO : "Romania",
  Country.RS : "Serbia",
  Country.RU : "Russian Federation (the)",
  Country.RW : "Rwanda",
  Country.SA : "Saudi Arabia",
  Country.SB : "Solomon Islands (the)",
  Country.SC : "Seychelles",
  Country.SD : "Sudan (the)",
  Country.SE : "Sweden",
  Country.SG : "Singapore",
  Country.SH : "Saint Helena, Ascension and Tristan da Cunha",
  Country.SI : "Slovenia",
  Country.SJ : "Svalbard and Jan Mayen",
  Country.SK : "Slovakia",
  Country.SL : "Sierra Leone",
  Country.SM : "San Marino",
  Country.SN : "Senegal",
  Country.SO : "Somalia",
  Country.SR : "Suriname",
  Country.SS : "South Sudan ",
  Country.ST : "Sao Tome and Principe",
  Country.SV : "El Salvador",
  Country.SX : "Sint Maarten (Dutch part)",
  Country.SY : "Syrian Arab Republic (the)",
  Country.SZ : "Swaziland",
  Country.TC : "Turks and Caicos Islands (the)",
  Country.TD : "Chad",
  Country.TF : "French Southern Territories (the)",
  Country.TG : "Togo",
  Country.TH : "Thailand",
  Country.TJ : "Tajikistan",
  Country.TK : "Tokelau",
  Country.TL : "Timor-Leste",
  Country.TM : "Turkmenistan",
  Country.TN : "Tunisia",
  Country.TO : "Tonga",
  Country.TR : "Turkey",
  Country.TT : "Trinidad and Tobago",
  Country.TV : "Tuvalu",
  Country.TW : "Taiwan (Province of China)",
  Country.TZ : "Tanzania, United Republic of",
  Country.UA : "Ukraine",
  Country.UG : "Uganda",
  Country.UM : "United States Minor Outlying Islands (the)",
  Country.US : "United States (the)",
  Country.UY : "Uruguay",
  Country.UZ : "Uzbekistan",
  Country.VA : "Holy See (the) [Vatican City State]",
  Country.VC : "Saint Vincent and the Grenadines",
  Country.VE : "Venezuela, Bolivarian Republic of ",
  Country.VG : "Virgin Islands (British)",
  Country.VI : "Virgin Islands (U.S.)",
  Country.VN : "Viet Nam",
  Country.VU : "Vanuatu",
  Country.WF : "Wallis and Futuna",
  Country.WS : "Samoa",
  Country.YE : "Yemen",
  Country.YT : "Mayotte",
  Country.ZA : "South Africa",
  Country.ZM : "Zambia",
  Country.ZW : "Zimbabwe",
];
}
