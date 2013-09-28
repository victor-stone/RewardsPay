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
        $offer1 = array( 'OfferID' => 100,
                          'Type' => 'D',
                          'Selected' => 1,
                          'DateFrom' => '2013/10/11 08:33:00',
                          'DateTo' => '2013/12/11 08:33:00',
                          'DaysToUse' => 28,
                          'Count' => 333,
                          'AmountDiscount' => 33,
                          'AmountMinimum' => 43,
                        'PointBonus' => 33,
                        'PointMultiplier' => 43,
                        'ArgoBonus' => 33,
                        'ArgoMultiplier' => 43,
                          'MultipleUse' => 0,
                          'PointBonus' => 33,
                        
                          'Description' => 'Everything I do is goin be funky from now on',
                          
                          'Name' => 'Funky Cleaners',
                          'Addr1' => '1234 First Ave.',
                          'City' => 'CityField',
                          'State' => 'ST',
                          'Zip' => '30009',
                          'Tel' => '301-555-1234',
                          'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
                          'Website' => 'http://funkychicken.com'
                        );

        $offer2 = array( 'OfferID' => 101,
                        'Type' => 'D',
                        'Selected' => 1,
                        'DateFrom' => '2013/10/11 08:33:00',
                        'DateTo' => '2013/12/11 08:33:00',
                        'DaysToUse' => 38,
                        'Count' => 1333,
                        'AmountDiscount' => 11,
                        'AmountMinimum' => 111,
                        'PointBonus' => 133,
                        'PointMultiplier' => 43,
                        'ArgoBonus' => 33,
                        'ArgoMultiplier' => 43,
                        'MultipleUse' => 0,
                        'PointBonus' => 33,
                        'Description' => 'offer2 Everything I do is goin be funky from now on',
                        
                        'Name' => 'Funky2 Cleaners',
                        'Addr1' => '1234 First Ave.',
                        'City' => 'CityField',
                        'State' => 'ST',
                        'Zip' => '30009',
                        'Tel' => '301-555-1234',
                        'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
                        'Website' => 'http://funky2chicken.com'
                        );

        $offer3 = array( 'OfferID' => 103,
                        'Type' => 'D',
                        'Selected' => 7,
                        'DateFrom' => '2013/10/11 08:33:00',
                        'DateTo' => '2013/12/11 08:33:00',
                        'DaysToUse' => 77,
                        'Count' => 777,
                        'AmountDiscount' => 733,
                        'AmountMinimum' => 743,
                        'PointBonus' => 373,
                        'PointMultiplier' => 437,
                        'ArgoBonus' => 3377,
                        'ArgoMultiplier' => 7437,
                        'MultipleUse' => 0,
                        'PointBonus' => 373,
                        'Description' => 'offer3 Everything I do is goin be funky from now on',
                        
                        'Name' => 'Funky3 Hot Dogs',
                        'Addr1' => '1234 First Ave.',
                        'City' => 'CityField',
                        'State' => 'ST',
                        'Zip' => '30009',
                        'Tel' => '301-555-1234',
                        'ImageURL' => 'http://'. $_SERVER[HTTP_HOST] .'/_appIcon.png',
                        'Website' => 'http://funkyhotdogs.com'
                        );
        
        $params = array( $offer1, $offer2, $offer3 );
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
        $reward1 = array( 'RewardID' => 200,
                         'Selected' => 1,
                         'AmountReward' => 233,
                         'DateFrom' => '2013/10/11 08:33:00',
                         'DateTo' => '2013/12/11 08:33:00',
                         'PointsRequired' => 300,
                         'AmountMinimum' => 200,
                         'MultipleUse' => 0,
                         
                         'Description' => 'Everything I do is goin be funky from now on',
                         
                         'Name' => 'Funky Cleaners',
                         'Addr1' => '1234 First Ave.',
                         'City' => 'CityField',
                         'State' => 'ST',
                         'Zip' => '30009',
                         'Tel' => '301-555-1234',
                         'ImageURL' => 'http://argotest/_appIcon.png',
                         'Website' => 'http://funkychicken.com'
                         );

        $reward2 = array( 'RewardID' => 201,
                         'Selected' => 1,
                         'AmountReward' => 500,
                         'DateFrom' => '2013/10/11 08:33:00',
                         'DateTo' => '2013/12/11 08:33:00',
                         'PointsRequired' => 300,
                         'AmountMinimum' => 200,
                         'MultipleUse' => 0,
                         
                         'Description' => 'Everything I do is goin be funky from now on',
                         
                         'Name' => 'World Around You',
                         'Addr1' => '1234 First Ave.',
                         'City' => 'CityField',
                         'State' => 'ST',
                         'Zip' => '30009',
                         'Tel' => '301-555-1234',
                         'ImageURL' => 'http://argotest/_appIcon.png',
                         'Website' => 'http://chicken.com'
                         );
        
        $params = array( $reward1, $reward2 );

        $value['Rewards'] = $params;
        break;
    }
     
    case 'MerchantLocationRewardList':
    {
        
        /*
        (Type D is discount, B is Bonus)
        > MToken, MLocID
        < Status, Message, RewardList {RewardID, DateFrom, DateTo, AmountReward, AmountMinimum, MultipleUse, PointsRequired}
         */
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
        $params = array( $m_reward_1, $m_reward_2, $m_reward_3, $m_reward_4, $m_reward_5  );
        
        $value['RewardList'] = $params;

        break;
        
    }

        /*
    case 'ConsActivateReward'
    {
        
        // /ConsActivateReward
        // >AToken, RewardID
        // <Status, Message, UserMessage
         
        $value['UserMessage'] = @"Merchant reward redeemed!";
        break;
    }
         */
        
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