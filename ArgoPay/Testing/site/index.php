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

$value = array( 'Status' => 0, 'Message' => ''
               //,'rawPostData' => $HTTP_RAW_POST_DATA, 'callingParams' => $parameters
               );

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
                     'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
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
                     'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
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
                     'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
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
                    'LongDescription' => 'This is the loooong description that is foobar.',
                    
                    'Description' => 'Everything I do is goin be funky from now on',
                    
                    'Name' => 'Funky Cleaners',
                    'Addr1' => '1234 First Ave.',
                    'City' => 'CityField',
                    'State' => 'ST',
                    'Zip' => '30009',
                    'Tel' => '301-555-1234',
                    'Lat' => 39.067884,
                    'Long' => -77.080239,
                    'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
                    'Website' => 'http://funkychicken.com'
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
                    
                    'Description' => 'offer2 Everything I do is goin be funky from now on',
                    'LongDescription' => 'This is the 2 loooong description that is foobar.',
                    'Name' => 'Funky2 Cleaners',
                    'Addr1' => '1234 First Ave.',
                    'City' => 'CityField',
                    'State' => 'ST',
                    'Lat' => 39.067884,
                    'Long' => -77.080239,
                    'Zip' => '30009',
                    'Tel' => '301-555-1234',
                    'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
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
                    'Description' => 'offer3 Everything I do is goin be funky from now on',
                    'LongDescription' => 'This is 3 the loooong description that is foobar.',
                    
                    'Name' => 'Funky3 Hot Dogs',
                    'Addr1' => '1234 First Ave.',
                    'City' => 'CityField',
                    'State' => 'ST',
                    'Lat' => 39.067884,
                    'Long' => -77.080239,
                    'Zip' => '30009',
                    'Tel' => '301-555-1234',
                    'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
                    'Website' => 'http://funkyhotdogs.com'
                    );
    
    return array( $offer1, $offer2, $offer3 );
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
                         'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
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
                         'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
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
                        
                         'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
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

        $value['Description'] = 'Everything I do is goin be funky from now on';
        
        $value['Name'] = 'World Around You';
        $value['Addr1'] = '1234 First Ave.';
        $value['Category'] = 'Food & Pinball Machines';
        $value['City'] =  'CityField';
        $value['Lat'] =  39.067884;
        $value['Long'] =  -77.080239;
        $value['State'] =  'ST';
        $value['Zip'] =  '30009';
        $value['Tel'] = '301-555-1234';
        $value['ImageURL'] = 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png';
        $value['Website'] =  'http://chicken.com';
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
        $value['PayAmounts'] =  array( array( 'Desc'=> 'Don\'t care', 'Amount'=> 32.99 ) );
        $value['Amounts'] =  array(  array( 'Type' => 'X', 'Amount'=> 20.00 ),
                                   array( 'Type'=> 'Q', 'Amount'=> 3.22 )
                                   );
        $value['TotalAmount'] = 54.9;
        $value['MerchName'] = 'Wine Gallery';
        $value['MerchLocation'] = 'DontCareVille, NY';
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

$output = $json->encode($value);

print($output);

?>