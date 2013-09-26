<?

header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: text/json');

// phpinfo();

// requires PEAR installation
require_once "JSON.php";


$json = new Services_JSON();
 
//convert php object to json 
 
// assumes Content-Type 'application/json'
$parameters = $json->decode($HTTP_RAW_POST_DATA);

$value = array( 'Status' => 0, 'Message' => '', 'callingParams' => $parameters );
 
 switch($_REQUEST['cmd'] )
 {
    case 'ConsumerLogin':
    {
        /*
           /ConsumerLogin
            > Email, Password, InToken
            < Status, Message, AToken, AccountID
        */
        $value['AToken'] = 'A-Magic-Token';
        $value['AccountID'] = 'Some-Account-ID';
        break;
    }
    
    case 'ConsActivateOffer':
    {
        /*
           /ConsActivateOffer
            >AToken, OfferID
            <Status, Message, UserMessage
        */
        $value['UserMessage'] = 'Your doodad has been activated and now in your wallet';
        break;    
    }
    
    case 'ConsumerGetAvailableOffers':
    {
         /*
         offers:
         Offers {OfferID, Type, Selected, DateFrom, DateTo, DaysToUse, Count, AmountDiscount, 
                AmountMinimum, PointBonus, PointMultiplier, ArgoBonus, ArgoMultiplier, 
               Nam, Addr1, Addr2, City, State, Zip, Tel, Lat, Long, Description, ImageURL, Website}
         */
 
        $params = array(   
                        array( 'OfferID' => 100,
                               'Type' => 'D', 
                               'Selected' => 1, 
                               'DaysToUse' => 28, 
                               'PointBonus' => 33,
                                'Nam' => 'Funky Cleaners', 
                                'Addr1' => '1234 First Ave.',
                                'City' => 'CityField',
                                'State' => 'ST',
                                'DateFrom' => '10/11/2013 08:33:00',
                                'Zip' => '30009',
                                'Tel' => '301-555-1234',
                                'Description' => 'Everything I do is goin be funky from now on',
                                'ImageURL' => 'http://argotest/_appIcon.png',
                                'Website' => 'http://funkychicken.com'
                                ),
                        array( 'OfferID' => 200,
                            'Type' => 'D', 
                               'Selected' => 1, 
                               'DaysToUse' => 45, 
                               'PointBonus' => 33,
                                'Nam' => 'World Around You', 
                                'Addr1' => '1234 First Ave.',
                                'City' => 'CityField',
                                'State' => 'ST',
                                'Zip' => '30009',
                                'Tel' => '301-555-1234',
                                'Description' => 'We loved each other we just couldn\'t get it on.',
                                'ImageURL' => 'http://argotest/_appIcon.png',
                                'Website' => 'http://funkychicken.com'
                                ),
                            );
            $value['Offers'] = $params;
            break;
                                
    }
    default:
    {
        $value['Status'] = -1;
        $value['Message'] = 'Unknown Request';
    }
 }
 
$output = $json->encode($value);

print($output);

?>