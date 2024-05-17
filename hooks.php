<?php
/**
 * Created by HARY-IT
 * User: HARY-IT
 * Project name freelance
 * 10.02.2024 00:00
 * Haryono Kudadiri <haryonokudadiri71@gmail.com>
 */

use Illuminate\Database\Capsule\Manager as Capsule;

use WHMCS\View\Menu\Item as MenuItem;

add_hook('InvoiceCancelled', 1, function ($vars) {

    $invoiceid = $vars['invoiceid'];

    $lines = Capsule::table('tblinvoiceitems')
                    ->where('invoiceid', $invoiceid)
                    ->get();


    foreach ($lines as $k => $v) {

        if ($v->type == 'Hosting') {
            $hosting = Capsule::table('tblhosting')
                              ->where('id', $v->relid)
                              ->first();

            $nextdue = $hosting->nextduedate;
            if (strlen($nextdue) > 5) {
                Capsule::table('tblhosting')
                       ->where('id', $v->relid)
                       ->update(['nextinvoicedate' => $nextdue]);

                $nextdue = date('Y-m-d', strtotime('+1 day', $nextdue));
                Capsule::table('tblinvoiceitems')
                       ->where('id', $v->id)
                       ->update(['duedate' => $nextdue]);
            }
        }

        if ($v->type == 'Addon') {
            $hosting = Capsule::table('tblhostingaddons')
                              ->where('id', $v->relid)
                              ->first();
            $nextdue = $hosting->nextduedate;
            if (strlen($nextdue) > 5) {
                Capsule::table('tblhostingaddons')
                       ->where('id', $v->relid)
                       ->update(['nextinvoicedate' => $nextdue]);

                $nextdue = date('Y-m-d', strtotime('+1 day', $nextdue));
                Capsule::table('tblinvoiceitems')
                       ->where('id', $v->id)
                       ->update(['duedate' => $nextdue]);
            }
        }


    }
});


add_hook('ClientAreaNavbars', 1, function ($vars) {

    $setting = Capsule::table('tblconfiguration')
                     ->where('setting', 'hosting_renew_showinallpages')->first();

    if($setting->value != 1){
        return;
    }


    $addon_uri = explode(DIRECTORY_SEPARATOR, __FILE__);
    $addon_name = $addon_uri[count($addon_uri) - 2];

    $primaryNavbar   = Menu::primaryNavbar();
    // Kullanıcı giriş yapmışsa işlem yap
    if (!is_null($primaryNavbar->getChild('Services'))) {
        // 'Hizmetlerim' menüsünü bul
        $servicesMenu = $primaryNavbar->getChild('Services');

        // 'Hizmetlerim' menüsüne yeni bir link ekleyin
        if (!is_null($servicesMenu)) {
            $servicesMenu->addChild('Hostingrenew Divider', array(
                'label' => '', // Görünecek isim
                'uri' => '#', // Ayırıcı için yönlendirme adresi gerekmez
                'order' => 43, // Menüdeki sıralama konumu
                'attributes' => array(
                    'class' => 'nav-divider', // Ayırıcı için CSS sınıfı
                ),
            ));
            $servicesMenu->addChild('Custom Module Link', array(
                'label' => 'Layanan & Perpanjangan Domain', // Görünecek isim
                'uri' => 'index.php?m='.$addon_name, // Linkin yönlendireceği adres
                'order' => 45, // Menüdeki sıralama konumu
            ));
        }
    }
});


add_hook('ClientAreaSecondarySidebar', 1, function  ($secondaryNavbar) {
    // Kullanıcı giriş yapmış ve bir hosting id'si varsa işlem yap
    if (!is_null($secondaryNavbar) && isset($_GET['id']) && in_array($_GET['action'],['productdetails','domaindetails']) && $_GET['id'] > 0){
        // Hosting id'sini al
        $relatedid = $_GET['id'];

        $type='hosting';
        if($_GET['action'] == 'domaindetails'){
            $type='domain';
        }

        $setting = Capsule::table('tblconfiguration')
                     ->where('setting', 'hosting_renew_showin'.$type)->first();
        if($setting->value != 1){
            return;
        }

        // Eğer sekonder navbar'da 'Services' menüsü varsa, onu al
        if (!is_null($secondaryNavbar->getChild(($type=='hosting'?'Pembaruan Layanan':'Pembaruan Nama Domain')))) {
            $servicesMenu = $secondaryNavbar->getChild(($type=='hosting'?'Pembaruan Layanan':'Pembaruan Nama Domain'));
        } else {
            // Yoksa, 'Services' menüsünü oluştur
            $servicesMenu = $secondaryNavbar->addChild(($type=='hosting'?'Pembaruan Layanan':'Pembaruan Nama Domain'));
        }



        // 'Services' menüsüne 'Renew Hosting' öğesini ekle
        $servicesMenu->addChild(($type=='hosting'?'Pembaruan Layanan':'Pembaruan Nama Domain'), array(
            'label' => 'Perpanjang Sekarang',
            'uri' => '/index.php?m=hosting_renew&'.($type=='hosting'?'hostingid':'domainid').'=' . $relatedid,
            'order' => 10, // Menüdeki sıralama konumu
        ));
    }
});



add_hook('ClientAreaHomepagePanels', 1, function($homePagePanels) {

    $setting = Capsule::table('tblconfiguration')
                     ->where('setting', 'hosting_renew_showsummaryonhomepage')->first();

    if($setting->value != 1){
        return;
    }


    $newPanel = $homePagePanels->addChild(
        'hosting-renew-module',
        array(
            'name' => 'Hosting Renewal Module Panel',
            'label' => 'Modul Pembaruan Hosting',
            'icon' => 'fas fa-calendar-alt', //see http://fortawesome.github.io/Font-Awesome/icons/
            'order' => '1',
            'extras' => array(
                'color' => 'pomegranate', //see Panel Accents in template styles.css
                'btn-link' => 'index.php?m=hosting_renew',
                'btn-text' => 'Perpanjang',
                'btn-icon' => 'fas fa-sync',
            ),
        )
    );
    $newPanel->addChild(
        'hosting-renew-module-1',
        array(
            'label' => 'Anda dapat memperpanjang layanan dan nama domain Anda sebelum tanggal penagihan',
            'uri' => '#',
            'order' => 10,
        )
    );
});

