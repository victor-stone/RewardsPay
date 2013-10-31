<?
function doMessagePump()
{
    $apnsServer = 'ssl://gateway.push.apple.com:2195';

    /* Make sure this is set to the password that you set for your private key when you exported it to
        the .pem file using openssl on your OS X */
    $privateKeyPassword = 'U44qh'; // 2st@7wK+AR
     

    $message = 'ArgoPay reward notification';

    $deviceToken = $_REQUEST['devicetoken'];
    if( empty($deviceToken) )
    {
        // this is victor's iphone:
        $deviceToken = 'F0333F9CCD2547AB09B863D5E1F9AFC8869B2AD24CBE73EC3D53D1034D0AF558';
    }
    
    /* Replace this with the name of the file that you have placed by your PHP script file,
     containing your private key and certificate that you generated earlier */
    $pushCertAndKeyPemFile = 'EntPushCertificateAndKey.pem';
    
    if( !empty($_RESUEST['sandbox'] ) )
    {
        $apnsServer = 'ssl://gateway.sandbox.push.apple.com:2195';
        $pushCertAndKeyPemFile = 'PushCertificateAndKey.pem';
    }
    
    $stream = stream_context_create();
    stream_context_set_option( $stream, 'ssl', 'passphrase', $privateKeyPassword);
    stream_context_set_option( $stream, 'ssl', 'local_cert', $pushCertAndKeyPemFile);
    $connectionTimeout = 20;
    $connectionType = STREAM_CLIENT_CONNECT | STREAM_CLIENT_PERSISTENT;
    $connection = stream_socket_client( $apnsServer, $errorNumber, $errorString, $connectionTimeout, $connectionType, $stream);
    
    if (!$connection)
    {
        echo "Failed to connect to the APNS server. Error no = $ errorNumber < br/ >";
        exit;
    }
    else
    {
        echo "Successfully connected to the APNS. Processing... </ br >";
    }
    $messageBody['aps'] = array('alert' => $message,
                                'sound' => 'default',
                                'badge' => 2 );
    $payload = json_encode( $messageBody);
    $notification = chr(0) .
    pack('n', 32) .
    pack('H*', $deviceToken) .
    pack('n', strlen($payload)) .
    $payload;
    $wroteSuccessfully = fwrite( $connection, $notification, strlen( $notification));
    
    if ($wroteSuccessfully)
    {
        echo "Successfully sent the message < br/ >";
    }
    else
    {
        echo "Could not send the message < br/ >";
    }
    
    fclose( $connection);
    
    exit;
}

if( $_REQUEST['cmd'] === 'pump' )
{
   doMessagePump();
}

header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: text/json');

// phpinfo();

//convert php object to json

$ICON_HOST = 'timbregroove.org/apps'; // $ICON_HOST

// assumes Content-Type 'application/json'
$parameters = json_decode($HTTP_RAW_POST_DATA);

$value = array( 'Status' => 0, 'Message' => ''
               //,'rawPostData' => $HTTP_RAW_POST_DATA, 'callingParams' => $parameters
               );

$output = 0;

function addRewards()
{
    /*
     /ConsumerGetAvailableRewards (Limit is Quantity of records to return)
     (SortBy is (N)one, W-Newest First, (R)eady to use, (A)vailable to Select, (E)xpiring Soon)
     (Selected means that the offer has already been selected by the consumer)
     (Redeemable means only offers that the consumer can now redeem instead of all rewards (Y/N))
     > AToken, Lat, Long, Distance, Redeemable, SortBy
     < Status, Message, Rewards {RewardID, DateFrom, Selected, Selectable, DateTo, AmountReward, 
     AmountMinimum, MultipleUse, PointsRequired
     MLocID, Name, Category, Addr1, Addr2, City, State, Zip, Tel, Lat, Long, Description, LongDescription, ImageURL, Website}
     */
    $reward1 = array(
                     'RewardID' => 200,
                     'DateFrom' => '2013-10-11 08:33:00',
                     'Selected' => 'Y',
                     'Selectable' => 'Y',
                     'DateTo' => '2013-12-11 08:33:00',
                     'AmountReward' => 8,
                     'AmountMinimum' => 200,
                     'MultipleUse' => 0,
                     'PointsRequired' => 300,
                     
                     'LongDescription' => 'This is 1 the loooong description that is foobar.',
                     
                     'Description' => 'Everything I do is goin be funky from now on',
                     
                     'Name' => 'Funky Cleaners',
                     'Addr1' => '1234 First Ave.',
                     'City' => 'CityField',
                     'Lat' => 39.067884,
                     'Long' => -77.080239,
                     'State' => 'ST',
                     'Zip' => '30009',
                     'Tel' => '301-555-1234',
                     'ImageURL' => 'http://'. $ICON_HOST .'/_appIcon.png',
                     'Website' => 'http://funkychicken.com'
                     );
    
    $reward2 = array(
                     'RewardID' => 201,
                     'DateFrom' => '2013-10-11 08:33:00',
                     'Selected' => 'N',
                     'Selectable' => 'Y',
                     'DateTo' => '2013-12-11 08:33:00',
                     'AmountReward' => 12,
                     'AmountMinimum' => 200,
                     'MultipleUse' => 0,
                     'PointsRequired' => 300,
                     
                     'LongDescription' => 'This is 2 the loooong description that is foobar.',
                     
                     'Description' => 'Everything I do is goin be funky from now on',
                     
                     'Name' => 'World Around You',
                     'Addr1' => '1234 First Ave.',
                     'City' => 'CityField',
                     'Lat' => 39.067884,
                     'Long' => -77.080239,
                     'State' => 'ST',
                     'Zip' => '30009',
                     'Tel' => '301-555-1234',
                     'ImageURL' => 'http://'. $ICON_HOST .'/_appIcon.png',
                     'Website' => 'http://chicken.com'
                     );
    
    $reward3 = array(
                     'RewardID' => 203,
                     'DateFrom' => '2013-10-11 08:33:00',
                     'Selected' => 'N',
                     'Selectable' => 'N',
                     'DateTo' => '2013-12-11 08:33:00',
                     'AmountReward' => 20,
                     'AmountMinimum' => 300,
                     'MultipleUse' => 0,
                     'PointsRequired' => 400,
                     
                     'LongDescription' => 'This is 3 the loooong description that is foobar.',
                     
                     'Description' => 'Everything I do is goin be funky from now on',
                     
                     'Name' => 'World Around You',
                     'Addr1' => '1234 First Ave.',
                     'City' => 'CityField',
                     'Lat' => 39.067884,
                     'Long' => -77.080239,
                     'State' => 'ST',
                     'Zip' => '30009',
                     'Tel' => '301-555-1234',
                     'ImageURL' => 'http://'. $ICON_HOST .'/_appIcon.png',
                     'Website' => 'http://chicken.com'
                     );
    
    /*
     $m_reward_1 = array(
     'RewardID' => '800',
     'DateFrom' => '2013/10/01 01:01:01',
     'DateTo' => '2013/11/01 01:01:01',
     'AmountReward' => 800,
     'AmountMinimum' => 200,
     'MultipleUse' => 0,
     'PointsRequired' => 50
     );
     $m_reward_2 = array(
     'RewardID' => '801',
     'DateFrom' => '2013/10/01 01:01:01',
     'DateTo' => '2013/11/01 01:01:01',
     'AmountReward' => 800,
     'AmountMinimum' => 200,
     'MultipleUse' => 0,
     'PointsRequired' => 100
     );
     $m_reward_3 = array(
     'RewardID' => '802',
     'DateFrom' => '2013/10/01 01:01:01',
     'DateTo' => '2013/11/01 01:01:01',
     'AmountReward' => 800,
     'AmountMinimum' => 200,
     'MultipleUse' => 0,
     'PointsRequired' => 200
     );
     $m_reward_4 = array(
     'RewardID' => '803',
     'DateFrom' => '2013/10/01 01:01:01',
     'DateTo' => '2013/11/01 01:01:01',
     'AmountReward' => 800,
     'AmountMinimum' => 200,
     'MultipleUse' => 0,
     'PointsRequired' => 300
     );
     $m_reward_5 = array(
     'RewardID' => '804',
     'DateFrom' => '2013/10/01 01:01:01',
     'DateTo' => '2013/11/01 01:01:01',
     'AmountReward' => 800,
     'AmountMinimum' => 400,
     'MultipleUse' => 0,
     'PointsRequired' => 80
     );
     */
    return array( $reward1, $reward2, $reward3 );
    
}

function addOffers()
{
    /*
    /ConsumerGetAvailableOffers   (Limit is Quantity of Records to return)
    (SortBy is (N)one, W-Newest First, (R)eady to use, (A)vailable to Select, (E)xpiring Soon)
    (Selected means that the offer has already been selected by the consumer)
    > AToken, Lat, Long, Distance, Limit, SortBy
    < Status, Message, Offers: {OfferID, Type, Selected, DateFrom, DateTo, DaysToUse, Count,
     AmountDiscount, AmountMinimum, PointBonus, PointMultiplier, ArgoBonus, ArgoMultiplier,
        MLocID, Name, Category, Addr1, Addr2, City, State, Zip, Tel, Lat, Long, Description,
     LongDescription, ImageURL, Website}
     */
    
    $offer1 = array( 'OfferID' => 100,
                    'Type' => 'D',
                    'Selected' => 'Y',
                    'DateFrom' => '2013-10-11 08:33:00',
                    'DateTo' => '2013-12-11 08:33:00',
                    'DaysToUse' => 28,
                    'Count' => 333,
                    'AmountDiscount' => 33,
                    'AmountMinimum' => 43,
                    'PointBonus' => 33,
                    'PointMultiplier' => 43,
                    'ArgoBonus' => 33,
                    'ArgoMultiplier' => 43,
                    'MultipleUse' => 0,
                    'LongDescription' => 'Red, white, pink? Wines are colorful but what does that mean? First, you need to know that wines are from grapes. In reality, grapes come in only two basic colors. Red and white. The pinks, also called “blush” come from leaving the red skin in contact with the grape until it takes on a pink color.',
                    
                    'Description' => 'Fine wines for fine occaisions',
                    
                    //         //5101 Great America Pkwy  Santa Clara, CA 95054

                    'Name' => 'Apex Wine',
                    'Addr1' => '5101 Great America Pkwy',
                    'City' => 'Santa Clara',
                    'State' => 'CA',
                    'Zip' => '95054',
                    'Tel' => '415-714-6000',
                    'Lat' =>  37.405161,
                    'Long' => -121.976592,
                    'ImageURL' => 'http://'. $ICON_HOST .'/_appIcon.png',
                    'Website' => 'http://apexwine.com'
                    );
    
    $offer2 = array( 'OfferID' => 101,
                    'Type' => 'D',
                    'Selected' => 'N',
                    'DateFrom' => '2013-10-11 08:33:00',
                    'DateTo' => '2013-12-11 08:33:00',
                    'DaysToUse' => 38,
                    'Count' => 1333,
                    'AmountDiscount' => 11,
                    'AmountMinimum' => 111,
                    'PointBonus' => 133,
                    'PointMultiplier' => 43,
                    'ArgoBonus' => 33,
                    'ArgoMultiplier' => 43,
                    
                    'Description' => 'One price, affordable, same day service.',
                    'LongDescription' => 'This is the 2 loooong description that is foobar.',
                    'Name' => 'Funky Cleaners',
                    'Addr1' => '1234 First Ave.',
                    'City' => 'CityField',
                    'State' => 'ST',
                    'Lat' => 39.067884,
                    'Long' => -77.080239,
                    'Zip' => '30009',
                    'Tel' => '301-555-1234',
                    'ImageURL' => 'http://'. $ICON_HOST .'/_appIcon.png',
                    'Website' => 'http://funky2chicken.com'
                    );
    
    
    $offer3 = array( 'OfferID' => 103,
                    'Type' => 'D',
                    'Selected' => 'Y',
                    'DateFrom' => '2013-10-11 08:33:00',
                    'DateTo' => '2013-12-11 08:33:00',
                    'DaysToUse' => 77,
                    'Count' => 777,
                    'AmountDiscount' => 733,
                    'AmountMinimum' => 743,
                    'PointBonus' => 373,
                    'PointMultiplier' => 437,
                    'ArgoBonus' => 3377,
                    'ArgoMultiplier' => 7437,
                    'Description' => 'Come have your birthday party at Barking Hot!',
                    'LongDescription' => 'Come have your birthday party at Barking Hot!',
                    
                    'Name' => 'Barking Hot Dogs',
                    'Addr1' => '1234 First Ave.',
                    'City' => 'CityField',
                    'State' => 'ST',
                    'Lat' => 39.067884,
                    'Long' => -77.080239,
                    'Zip' => '30009',
                    'Tel' => '301-555-1234',
                    'ImageURL' => 'http://'. $ICON_HOST .'/_appIcon.png',
                    'Website' => 'http://funkyhotdogs.com'
                    );
    
    return array( $offer1, $offer2, $offer3 );
}

function getDemoMerchants()
{
    return '{"Status": 0, "Message": "OK", "Locations": [{"Website": "", "City": "Santa Clara", "Name": "Apex Wine", "Zip": "02215", "Distance": 23.21, "ImageURL": "", "Category": "Liquor Store", "Long": "-121.97695200", "State": "MA", "MLocID": "7", "Addr1": "5105 Great America Parkway", "Lat": "37.40516100", "Addr2": "", "Description": ""}, {"Website": "", "City": "Santa Clara", "Name": "Mexican Restaurant", "Zip": "95404", "Distance": 13.25, "ImageURL": "", "Category": "Restaurant", "Long": "-121.96356900", "State": "CA", "MLocID": "4", "Addr1": "2215 Tasman Drive", "Lat": "37.24077000", "Addr2": "", "Description": ""}, {"Website": "", "City": "Santa Clara", "Name": "ABC Jewelry Store", "Zip": "95404", "Distance": 23.11, "ImageURL": "", "Category": "Jewelry", "Long": "-121.98575400", "State": "CA", "MLocID": "2", "Addr1": "4800 Patrick Henry Drive", "Lat": "37.40028700", "Addr2": "", "Description": ""}, {"Website": "", "City": "Santa Clara", "Name": "Joe\'s Restaurant", "Zip": "95404", "Distance": 23.11, "ImageURL": "", "Category": "Restaurant", "Long": "-121.97100100", "State": "CA", "MLocID": "1", "Addr1": "5151 Stars and Stripes Drive", "Lat": "37.40581200", "Addr2": "", "Description": ""}, {"Website": "", "City": "Santa Clara", "Name": "David\'s Chinese Fast Food", "Zip": "95404", "Distance": 23.51, "ImageURL": "", "Category": "Restaurant", "Long": "-121.97804000", "State": "CA", "MLocID": "5", "Addr1": "5350 Great America Parkway", "Lat": "37.40967500", "Addr2": "", "Description": ""}, {"Website": "", "City": "Santa Clara", "Name": "Anna\'s Tacos", "Zip": "95404", "Distance": 23.51, "ImageURL": "", "Category": "Restaurant", "Long": "-121.97804000", "State": "CA", "MLocID": "6", "Addr1": "5350 Great America Parkway", "Lat": "37.40967500", "Addr2": "", "Description": ""}, {"Website": "", "City": "Santa Clara", "Name": "Friendly Pet Shop", "Zip": "95404", "Distance": 23.64, "ImageURL": "", "Category": "Pets", "Long": "-121.98552700", "State": "CA", "MLocID": "3", "Addr1": "5440 Patrick Henry Drive", "Lat": "37.40885200", "Addr2": "", "Description": ""}]}';
}

function getDemoRewards()
{
    return '{"Status": 0, "Message": "OK", "Rewards": [{"Category": "Wine", "City": "Santa Clara", "Zip": "94202", "Selected": "N", "Long": "-121.97695200", "State": "CA", "MLocID": "7", "RewardID": "1", "Name": "Apex Wine", "Website": "http://www.argopay.com", "Description": "Get $10 with for 100 Points", "DateFrom": "2013-01-01", "Lat": "37.40516100", "Selectable": "Y", "AmountMinimum": "100.00", "DateTo": "2013-12-31", "ImageURL": "imageurl", "PointsRequired": "100", "Tel": "6175551212", "Addr2": "", "AmountReward": "10.00", "Addr1": "5105 Great America Parkway"}, {"Category": "Restaurant", "City": "Santa Clara", "Zip": "94202", "Selected": "N", "Long": "-121.971001", "State": "CA", "MLocID": "7", "RewardID": "2", "Name": "Joe\'s Restaurant", "Website": "http://www.joesamerican.com", "Description": "Get $10 with for 100 Points", "DateFrom": "2013-01-01", "Lat": "37.405812", "Selectable": "Y", "AmountMinimum": "100.00", "DateTo": "2013-12-31", "ImageURL": "imageurl", "PointsRequired": "100", "Tel": "6175551212", "Addr2": "", "AmountReward": "10.00", "Addr1": "5151 Stars and Stripes Drive"}]}';
}

switch($_REQUEST['cmd'] )
{
    case 'ConsumerLogin':
    {
        /*
         /ConsumerLogin
         > Email, Password, InToken
         < Status, Message, AToken, AccountID
         */
        if( strcmp( $parameters->Email, "bogus" ) == 0 )
        {
            $value['Status'] = 1;
            $value['Message'] = 'Invalid username and password combination';
            $value['AToken'] = '';
            $value['AccountID'] = '';
        }
        else
        {
            $value['AToken'] = 'A-Magic-Token';
            $value['AccountID'] = 'Some-Account-ID';
        }
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
       // $value['Status'] = 400;
      //  $value['Message'] = 'This is a server generated error';
        $value['Offers'] = addOffers();
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
        $value['Rewards'] = addRewards();
        /*
        $output = getDemoRewards();
        print($output);
        exit;
         */
        break;
    }

    case 'MerchantLocationSearch_API':
    {
        $output = getDemoMerchants();
        print($output);
        exit;
        break;
    }
        
    case 'MerchantLocationSearch':
    {
        $merch1 = array(
                         'LongDescription' => 'This is 1 the loooong description that is foobar.',
                         'MLocID' => '101',
                         'Description' => 'Everything I do is goin be funky from now on',
                         'Category' => 'Category1',
                         'Name' => 'Funky Cleaners',
                         'Addr1' => '1234 First Ave.',
                         'Addr2' => 'addr2 for 1',
                         'City' => 'CityField',
                         'Lat' => 39.067884,
                         'Long' => -77.080239,
                         'State' => 'ST',
                         'Zip' => '30009',
                         'Tel' => '301-555-1234',
                         'ImageURL' => 'http://'. $ICON_HOST .'/_appIcon.png',
                         'Website' => 'http://funkychicken.com'
                         );
        
        $merch2 = array(
                         'LongDescription' => 'This is 2 the loooong description that is foobar.',
                         
                         'Description' => 'Everything I do is goin be funky from now on',
                        'MLocID' => '102',

                        'Category' => 'Category2',
                         'Name' => 'World Around You',
                         'Addr1' => '1234 First Ave.',
                         'City' => 'CityField',
                         'Lat' => 39.067884,
                        'Addr2' => 'addr2 for 2',
                         'Long' => -77.080239,
                         'State' => 'ST',
                         'Zip' => '30009',
                         'Tel' => '301-555-1234',
                         'ImageURL' => 'http://'. $ICON_HOST .'/_appIcon.png',
                         'Website' => 'http://chicken.com'
                         );
        
        $merch3 = array(
                         'LongDescription' => 'This is 3 the loooong description that is foobar.',
                        'MLocID' => '102',
                        
                         'Description' => 'Everything I do is goin be funky from now on',
                        'Category' => 'Category3',
                        
                         'Name' => 'World Around You',
                         'Addr1' => '1234 First Ave.',
                        'Addr2' => 'addr2 for 3',
                         'City' => 'CityField',
                         'Lat' => 39.067884,
                         'Long' => -77.080239,
                        
                        
                         'State' => 'ST',
                         'Zip' => '30009',
                         'Tel' => '301-555-1234',
                        
                         'ImageURL' => 'http://'. $ICON_HOST .'/_appIcon.png',
                         'Website' => 'http://chicken.com'
                         );
        
        $params = array( $merch1, $merch2, $merch3 );
        
        $value['Locations'] = $params;
        break;
    }
        
    case 'MerchantLocationDetail':
    {
        /*
         /MerchantLocationDetail (Displays the detail for a Merchant)
                                 (Shows all rewards and offers available for a merchant location
                                 (AToken: Optional if AToken is valid, then we also return consumer based data also.)
                                 (MLocID: Required.   Specifies a MLocID from previous call)
         >AToken, MLocID
         
         <MLocID, Name, Category, Addr1, Addr2, City, State, Zip, Tel, Lat, Long, Description, ImageURL, Website,
         
         ConsumerPoints,
         
         Offers: {OfferID, Type, Selected, DateFrom, DateTo, DaysToUse, Count, AmountDiscount, AmountMinimum,
                     PointBonus, PointMultiplier, ArgoBonus, ArgoMultiplier,
                     Description, LongDescription},
         
         Rewards: {RewardID, DateFrom, Selected, Selectable, DateTo, AmountReward,
                     AmountMinimum, MultipleUse, PointsRequired,
                     Description, LongDescription}
         
         */

        $value['Description'] = 'Fine wines for fine occasions.';
        //5101 Great America Pkwy  Santa Clara, CA 95054
        $value['Name'] = 'Apex Wine';
        $value['Addr1'] = '5101 Great America Pkwy';
        $value['Category'] = 'Wine';
        $value['City'] =  'Santa Clara';
        $value['Lat'] =  37.405161;
        $value['Long'] = -121.976592;
        $value['State'] =  'CA';
        $value['Zip'] =  '95054';
        $value['Tel'] = '415-708-6000';
        $value['ImageURL'] = 'http://'. $ICON_HOST .'/_appIcon.png';
        $value['Website'] =  'http://apexwine.com';
        $value['ConsumerPoints'] = 340;
        $value['Offers'] = addOffers();
        $value['Rewards'] = addRewards();
        break;
    }
        
    case 'ConsumerTransactionStart':
    {
        /*
         /ConsumerTransactionStart
         > AToken, QrData, Lat, Long, PayID
         < Status, Message, TransID
         */
        $value['TransID'] = 1200;
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
        $value['PayAmounts'] =  array( array( 'Desc'=> 'Don\'t care', 'Amount'=> 32.99 ) );
        $value['Amounts'] =  array(  array( 'Type' => 'X', 'Amount'=> 20.00 ),
                                   array( 'Type'=> 'Q', 'Amount'=> 3.22 )
                                   );
        $value['TotalAmount'] = 54.9;
        $value['MerchName'] = 'Apex Wine';
        $value['MerchLocation'] = 'Santa Clara, CA';
        $value['MerchRegister'] = 'Henry';
        $value['Category'] = 'Fine wines';
        
        break;
    }
        
    case 'ConsumerTransactionApprove':
    {
        /*
         /ConsumerTransactionApprove
         >AToken, TransID, Approve (Binary [Y/N])
         <Status, Message, UserMessage
         */
        if( strcmp( $parameters->Approve, 'N' ) == 0 )
            $value['UserMessage'] = 'You have cancelled the transaction.';
        else
            $value['UserMessage'] = 'Your transaction has been approved. Thanks for using ArgoPay!';
        break;
    }

    case 'ConsumerStatementSummary':
    {
        /*
         /ConsumerStatementSummary
         >AToken
         <AmountAvailable, AmountOutstanding, LastTransDate, LastPayDate, NextPayDate, NetPayAmount, ArgoPoints         
         */
        $value['AmountAvailable'] = 345.1;
        $value['AmountOutstanding'] = 456.0;
        $value['LastTransDate'] = '2013-09-02 03:40:12';
        $value['LastPayDate'] = '2013-09-22 03:40:12';
        $value['NextPayDate'] = '2013-09-11 03:40:12';
        $value['NetPayAmount'] = 222.99;
        $value['ArgoPoints'] = 678;
        break;
    }
        
    case 'ConsumerStatementDetail':
    {
        /*
         /ConsumerStatementDetail
         >AToken, DateFrom, DateTo
         <Status, Message, Transactions {Date, Type, Amount, AmountUnpaid, Description}
         
         */
        
        $trans1 = array( 'Date' => '2013-06-01 08:22:11',
                        'Type' => 'X',
                        'Amount' => 993.09,
                        'AmountUnpaid' => 323.35,
                        'Description' => "somewhere in america"
                        );
        $trans2 = array( 'Date' => '2013-06-02 08:22:11',
                        'Type' => 'X',
                        'Amount' => 93.09,
                        'AmountUnpaid' => 323.35,
                        'Description' => "Beach is Better"
                        );
        $trans3 = array( 'Date' => '2013-06-03 08:22:11',
                        'Type' => 'X',
                        'Amount' => 193.09,
                        'AmountUnpaid' => 323.35,
                        'Description' => "Nickels and Dimes"
                        );
        $trans4 = array( 'Date' => '2013-07-02 08:22:11',
                        'Type' => 'X',
                        'Amount' => 60.03,
                        'AmountUnpaid' => 323.35,
                        'Description' => "La Familia"
                        );
        
        $value['Transactions'] = array( $trans1,  $trans2,  $trans3,  $trans4 );
        break;
    }
        
    default:
    {
        $value['Status'] = -1;
        $value['Message'] = 'Unknown Request';
    }
}

$output = json_encode($value);

print($output);

?>