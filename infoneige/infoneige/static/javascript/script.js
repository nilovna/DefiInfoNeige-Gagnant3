$(document).ready(function() {
    /* MAP */
    var map;
    // initiate leaflet map
    map = new L.Map('cartodb-map', { 
        center: [45.508669900000000000,-73.553992499999990000],
        attributionControl: false,
        zoom: 13
    });

    L.tileLayer('http://{s}.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.png', {
        subdomains: ['otile1','otile2','otile3','otile4'],
        maxZoom: 18,
    }).addTo(map);

    map.locate({setView: true, maxZoom: 17});

    function onLocationFound(e) {
        var radius = e.accuracy / 2;

        L.marker(e.latlng, { draggable: true }).addTo(map)
            .bindPopup("Vous êtes à " + radius + " mètres près de ce point").openPopup();

    }

    var myIcon = L.icon({
        iconUrl: '${request.static_url("infoneige:static/images/pin-shoveler@2x.png")}',
        iconRetinaUrl: '${request.static_url("infoneige:static/images/pin-shoveler@2x.png")}',
        iconSize: [47, 55],
        iconAnchor: [22, 94],
        popupAnchor: [-3, -76],
    });

    L.marker([45.508183,-73.554094], {icon: myIcon}).addTo(map).bindPopup("<h3 class='subhead'>Jean-François Poulin</h3><p>Ma voiture est prise!</p><button>Aider</button>");
    L.marker([45.5392,-73.5414], {icon: myIcon}).addTo(map).bindPopup("<h3 class='subhead'>Daniel LeBlanc</h3><p>J'ai oublié ma pelle :(</p><button>Aider</button>");
    L.marker([45.51205360327094,-73.55393081903458], {icon: myIcon}).addTo(map).bindPopup("<h3 class='subhead'>Nilovna B-V.</h3><p>Ma batterie est à plat.</p><button>Aider</button>");
    map.on('locationfound', onLocationFound);

    function onLocationError(e) {
        alert(e.message);
    }

    map.on('locationerror', onLocationError);

    var layerUrl = 'http://nilovna.cartodb.com/api/v2/viz/8c583088-15d0-11e4-bbcf-0e230854a1cb/viz.json';

    cartodb.createLayer(map, layerUrl)
        .addTo(map)
        .on('done', function(layer) {
            all_layer = layer;
            layer.createSubLayer({
                sql: "SELECT * FROM cote",
                cartocss: '#cote { line-color: #e51c23; line-width: 7; line-opacity: 0.3;}'
            });
        }).on('error', function() {
            //log the error
        });


    map.on("zoomend", function(e) {
        if ( map.getZoom() >= 17 ){
        all_layer.show(); 
        } else { 
        all_layer.hide(); 
        }
    }); 

    $.widget("ui.dialog", $.extend({}, $.ui.dialog.prototype, {
        _title: function(title) {
            if (!this.options.title ) {
                title.html("&#160;");
            } else {
                title.html(this.options.title);
            }
        }
    }));

    if (screen.width <= 320)
        dialogMaxWidth = 250;
    else
        dialogMaxWidth = 300;


    /* DIALOGS */
    $("#dialog-questions").dialog({
        width: dialogMaxWidth,
        maxWidth: dialogMaxWidth,
        autoOpen:false, 
        title: "Contactez-nous",
        draggable:false,
        show: {effect:"fade", duration: 300},
        hide: {effect:"fade", duration: 100},
        //dialogClass: "no-close",
        buttons: [
        {
            text: "Annuler",
            "class": "btn-cancel",
            click: function() {
            $( this ).dialog( "close" );
            }
        },
        {
            text: "Envoyer",
            "class": "btn-action",
            click: function() {
            msg_sent = true;
            $(this).dialog("close");
            }
        }
        ],
        open: function(){
        msg_sent = false;
        }
    });

    $("#dialog-questions").on( "dialogclose", function( event, ui ) {
        if (msg_sent) {
        $("#dialog-questions-confirmation").dialog("open");
        }
    } );

    $("#dialog-help").on( "dialogclose", function( event, ui ) {
        if (help_msg_sent) {
        $("#dialog-help-confirmation").dialog("open");
        }
    } );

    $("#dialog-questions-confirmation").dialog({
        width: dialogMaxWidth,
        maxWidth: dialogMaxWidth,
        autoOpen:false, 
        title: "Confirmation",
        position: {my: "center", at: "center", of: $("body"),within: $("body") },
        draggable:false,
        show: {effect:"fade", duration: 300},
        hide: {effect:"fade", duration: 100},
        buttons: [
        {
            text: "Fermer",
            "class": "btn-cancel",
            click: function() {
            $( this ).dialog( "close" );
            }
        }
        ]
    });
    $("#dialog-help").dialog({
        width: dialogMaxWidth,
        maxWidth: dialogMaxWidth,
        autoOpen:false, 
        title: "J'ai besoin d'aide!",
        draggable:false,
        show: {effect:"fade", duration: 300},
        hide: {effect:"fade", duration: 100},
        buttons: [
        {
            text: "Annuler",
            "class": "btn-cancel",
            click: function() {
            $( this ).dialog( "close" );
            }
        },
        {
            text: "Envoyer",
            "class": "btn-action",
            click: function() {
            help_msg_sent = true;
            $( this ).dialog( "close" );
            }
        }
        ],
        open: function(){
        help_msg_sent = false;
        }
    });

    $("#dialog-help-confirmation").dialog({
        width: dialogMaxWidth,
        maxWidth: dialogMaxWidth,
        autoOpen:false, 
        title: "Aide envoyée",
        draggable:false,
        show: {effect:"fade", duration: 300},
        hide: {effect:"fade", duration: 100},
        //dialogClass: "no-close",
        buttons: [
        {
            text: "Fermer",
            "class": "btn-cancel",
            click: function() {
            $( this ).dialog( "close" );
            }
        } 
        ]
    });

    $("#dialog-favoris").dialog({
        width: dialogMaxWidth,
        maxWidth: dialogMaxWidth,
        autoOpen:false, 
        title: 'Favoris',
        draggable:false,
        show: {effect:"fade", duration: 300},
        hide: {effect:"fade", duration: 100},
        //dialogClass: "no-close",
        buttons: [
        {
            text: "Ajouter lieu actuel aux favoris",
            "class": "btn-default",
            click: function() {
            $( this ).dialog( "close" );

            }
        }
        ]
    });


    $("#dialog-settings").dialog({
        width: dialogMaxWidth,
        fluid: true,
        maxWidth: dialogMaxWidth,
        autoOpen:false, 
        title: 'Préférences',
        draggable:false,
        show: {effect:"fade", duration: 300},
        hide: {effect:"fade", duration: 100},
        open: function(){
        $('input[type="checkbox"]').iCheck({
            checkboxClass: 'icheckbox_square-blue',
        });
        },
        buttons: [
        {
            text: "Annuler",
            "class": "btn-cancel",
            click: function() {
            $( this ).dialog( "close" );
            }
        },
        {
            text: "Sauvegarder",
            "class": "btn-action",
            click: function() {
            $( this ).dialog( "close" );

            }
        }
        ]
    });



    $("#btn-favoris").on("click", function(){
        $("#dialog-favoris").dialog("open");
    });

    $("#btn-help").on("click", function(){
        $("#dialog-help").dialog("open");
    });

    $("#btn-questions").on("click", function(){
        $("#dialog-questions").dialog("open");
    });

    $("#btn-settings").on("click", function(){
        $("#dialog-settings").dialog("open");
    });
    $( "#tabs" ).tabs({
        show: {effect:"fade", duration: 300},
        hide: {effect:"fade", duration: 100},
    });

});
