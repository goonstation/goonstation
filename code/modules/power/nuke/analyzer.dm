/obj/machinery/power/nuke_analyzer
	var/html = {"<!doctype html>
<html>

<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Nuclear Material Analyzer</title>
    <link rel="stylesheet" type="text/css" href="http://cdn.goonhub.com/css/bootstrap.min.css?serverrev=16182" />
    <link rel="stylesheet" type="text/css" href="http://cdn.goonhub.com/css/bootstrap-responsive.min.css?serverrev=16182" />
    <script type="text/javascript" src="http://cdn.goonhub.com/js/jquery.min.js?serverrev=16182"></script>
    <script type="text/javascript" src="http://cdn.goonhub.com/js/jquery.migrate.js?serverrev=16182"></script>
    <style type="text/css">
        body {
            background-color: #170F0D;
            color: #746C48;
        }

        a:link {
            color: #98724C;
        }

        a:visited {
            color: #98724C;
        }

        a:hover {
            color: #AF652F;
        }

        .rs_table {
            margin: 20px;
            display: inline-block;
        }

        .rs_table th,
        .rs_table tr td {
            border: 1px solid #544B2E;
            border-collapse: collapse;
        }

        caption {
            text-transform: lowercase;
        }

        .rs_table th {
            color: #70A16C;
            font-weight: bold;
            text-transform: lowercase;
            text-align: left;
            padding-left: 5px;
        }

        .rs_table th: {
            color: #70A16C;
            font-weight: bold;
            text-transform: lowercase;
            text-align: left;
            padding-left: 5px;
        }

        .rs_table tbody tr th:first-child {
            padding-left: 0px;
            padding-right: 5px;
            text-align: right;
        }

        #stats_header {
            margin: 20px auto 20px auto;
            font-size: 20px;
            text-align: center;
        }

        #stats_header a {
            font-size: 16px;
        }

        .nav_active {
            text-transform: uppercase;
            font-size: 20px !important;
            color: #AF652F !important;
            letter-spacing: 4px;
            font-weight: bold;
        }

        .table_title {
            text-align: center;
            font-size: 20px;
        }

        .center {
            text-align: center;
        }

        .online {
            font-size: 2em;
            background-color: #7B854E;
            color: #E4DC8C;
        }

        .offline {
            font-size: 2em;
            background-color: #98724C;
            color: #E4DC8C;
        }

        .stats_tables {
            margin-top: 100px;
        }

        .y_label {
            text-align: right;
            font-weight: bold;
            font-family: monospace;
            padding-right: 5px;
        }

        td {
            text-align: left;
            font-family: monospace;
            padding-left: 5px;
            min-width: 90px;
        }

		.ib {
			display: inline-block;
		}

		.analyze { font-size: 2em; }
		#sample-state { margin-right:15px; }

		.left-pane {
			margin: 20px 0 0 40px;
			padding: 20px;
			width: 35%;
			border: 1px solid #AF652F;
			vertical-align: top;
		}
		.right-pane {
			vertical-align: top;
			margin: 20px 0 0 40px;
			padding: 20px;
			width: 35%;
			border: 1px solid #AF652F;
		}

		.bord {border: 1px solid #AF652F;}

		.item-icon {
			margin: 20px 0 0 10px;
			border: 1px solid #AF652F;
			padding:10px;
			height:128px;
			width:128px;
			text-align:center;
			display:inline-block;
			vertical-align:top;
		}

		.item-icon a {
			width:100%;
		}
		.nuke-pane-header {
			font-size: 2em;
			font-weight: bold;
			display: block;
			margin-bottom: 15px;
			margin-right:15px;
		}
		.nuke-prop-name {
			font-size:1.4em;
			text-decoration:underline;
		}
		.molecule {
			float:right;
			margin: 25px;
			vertical-align:top;
		}
    </style>
</head>

<body>
    <script type="text/javascript" src="http://cdn.goonhub.com/js/bootstrap.min.js?serverrev=16182"></script>
    <script type="text/javascript" src="http://cdn.goonhub.com/js/jsviews.min.js?serverrev=16182"></script>

	<div id="stats_header"><span class="nav_active">nuclear material analysis computer</span></div>

	<div class="ib left-pane">
		<span class="nuke-pane-header">Properties:</span><br />
		<span class="nuke-prop-name">Name:</span><span class="nuke-name">-</span><br />
		<span class="nuke-prop-name">Classification:</span><span class="nuke-class">-</span><br />
		<span class="nuke-prop-name">Quality:</span><span class="nuke-quality">-</span><br />
		<span class="nuke-prop-name">Partice Type:</span><span class="nuke-particle">-</span><br />
		<span class="nuke-prop-name">Emissivity:</span><span class="nuke-epv">-</span><br />
		<span class="nuke-prop-name">Thermal Volatility:</span><span class="nuke-hpe">-</span><br />
		<span class="nuke-prop-name">Absorptivity:</span><span class="nuke-absorb">-</span><br />
		<span class="nuke-prop-name">Excitability:</span><span class="nuke-kfactor">-</span><br />
	</div>
	<div class="ib right-pane">
		<span class="nuke-pane-header" style="display:inline;">Control:</span>
		<span id="sample-state" class="offline">NO SAMPLE</span>
		<a class="analyze" href="todo">Analyze Sample</a>
		<div class="item-icon">
			<a href="todo">insert here</a>
		</div>
		<div class="ib bord molecule"><img src="http://clipart-library.com/img/1824853.gif">
	</div>
</body>

</html>"}
