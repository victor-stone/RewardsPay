<?
header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: text/json');

// phpinfo();

require_once "JSON.php";
$json = new Services_JSON();

//convert php object to json

// assumes Content-Type 'application/json'
$parameters = $json->decode($HTTP_RAW_POST_DATA);

$value = array( 'Status' => 0, 'Message' => '', 'rawPostData' => $HTTP_RAW_POST_DATA, 'callingParams' => $parameters );

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
                              'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
                              'Website' => 'http://funkychicken.com'
                              ),
                        array( 'OfferID' => 200,
                              'Type' => 'D',
                              'Selected' => 0,
                              'DaysToUse' => 45,
                              'PointBonus' => 33,
                              'Nam' => 'World Around You',
                              'Addr1' => '1234 First Ave.',
                              'City' => 'CityField',
                              'State' => 'ST',
                              'Zip' => '30009',
                              'Tel' => '301-555-1234',
                              'Description' => 'We loved each other we just couldn\'t get it on.',
                              'ImageURL' => 'http://'. $HTTP_HOST .'/_appIcon.png',
                              'Website' => 'http://funkychicken.com'
                              ),
                        );
        $value['Offers'] = $params;
        break;
        
    }
        
    case 'ConsActivateReward':
    {
        /*
         /ConsActivateReward
         >AToken, RewardID
         <Status, Message, UserMessage
         */
        
        $value['UserMessage'] = 'Your reward has been granted';
        break;
    }
        
    case 'ConsumerGetAvailableRewards':
    {
        /*
         /ConsumerGetAvailableRewards (Limit is Quantity of records to return)
         (SortBy is (N)one, W-Newest First, (R)eady to use, (A)vailable to Select, (E)xpiring Soon)
         (Selected means that the offer has already been selected by the consumer)
         
         > AToken, Lat, Long, Distance, Limit, SortBy
         < Status, Message, Rewards
         {RewardID, DateFrom, Selected, DateTo, Count, AmountReward, AmountMinimum, MultipleUse,
         Nam, Addr1, Addr2, City, State, Zip, Tel, Lat, Long, Description, ImageURL, Website}
         */
        
        $params = array(
                        array( 'RewardID' => 200,
                              'Selected' => 1,
                              'AmountReward' => 33,
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
                        array( 'RewardID' => 201,
                              'Selected' => 0,
                              'AmountReward' => 33,
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
        $value['Rewards'] = $params;
        break;
    }
        
    case 'ConsumerTransactionStart':
    {
        /*
         /ConsumerTransactionStart
         > AToken, QrData, Lat, Long, PayID
         < Status, Message, TransID
         */
        $value['TransID'] = 'Some-trans-ID';
        break;
    }
        
    case 'ConsumerTransactionStatus':
    {
        /*
         /ConsumerTransactionStatus
         >  AToken, TransID
         <  Status, Message, TransStatus, Amounts: {Type,Amount),
         TotalAmount, PayAmounts: {Desc, Amount},
         MerchName, MerchLocation, MerchRegister
         */
        $value['TransStatus'] = 'A';
        $value['Amounts'] =  array(  array( 'Type' => 'X', 'Amount'=> 20.00 ),
                                   array( 'Type'=> 'Q', 'Amount'=> 3.22 )
                                   );
        $value['TotalAmount'] = 23.22;
        $value['PayAmounts'] =  array( array( 'Desc'=> 'Don\'t care', 'Amount'=> 32.99 ) );
        $value['MerchName'] = 'Whooley Bully';
        $value['MerchLocation'] = 'DontCareVille, NY';
        $value['MerchRegister'] = 'Henry';
        
        break;
    }
        
    case 'ConsumerTransactionApprove':
    {
        /*
         /ConsumerTransactionApprove
         >AToken, TransID, Approve (Binary [Y/N])
         <Status, Message, UserMessage
         */
        if( strcmp( $parameters->Approve, 'Y' ) == 0 )
            $value['UserMessage'] = 'You have spent wisely. Honest. Thanks for using ArgoPay!';
        else
            $value['UserMessage'] = 'You can cancelled the transaction.';
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