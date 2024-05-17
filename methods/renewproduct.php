<?php
/**
 * Created by HARY-IT
 * User: HARY-IT
 * Project name freelance
 * 10.02.2024 00:00
 * Haryono Kudadiri <haryonokudadiri71@gmail.com>
 */

use Illuminate\Database\Capsule\Manager as Capsule;

$_addons = $result = [];

if ($_REQUEST['type'] == 'hosting') {
    $_product = Capsule::table('tblhosting')
                       ->where('id', $_REQUEST['hostingid'])
                       ->where('userid', $userid)
                       ->first();


    if (isset($_product->id)) {
        $_addons = Capsule::table('tblhostingaddons')
                          ->where('hostingid', $_product->id)
                          ->wherein('id', explode(',', $_REQUEST['addonsid']))
                          ->get();

        if (count($_addons) > 0) {
            $aids = array();
            foreach ($_addons as $kad => $vad) {
                $aids[] = $vad->id;
            }
            $_addons = Capsule::table('tblhostingaddons')
                              ->whereIn('id', $aids)
                              ->update([
                                  'nextduedate'     => $_product->nextduedate,
                                  'nextinvoicedate' => $_product->nextinvoicedate
                              ]);
        }
    }

    if (isset($_product->id)) {

        $apidata = array(
            'noemails'   => false,
            'clientid'   => $userid,
            'serviceids' => array($_product->id)
        );

        if (count($_addons) > 0) {
            foreach ($_addons as $kad => $vad) {
                $apidata['addonids'][] = $vad->id;
            }
        }

        $results = localAPI('geninvoices', $apidata, 'admin');
        if ($results['latestinvoiceid'] > 0) {
            $result['result']    = 'success';
            $result['invoiceid'] = $results['latestinvoiceid'];
        }
    }
}

if ($_REQUEST['type'] == 'domain') {

    $result=[
        'result'=>'redirect',
        'querystring'=>"renewalids[]=".$_REQUEST['domainid']."&renewalperiod[".$_REQUEST['domainid']."]=".$_REQUEST['years']
    ];


}


$result['type'] = 'json';
$apiresponse    = $result;

