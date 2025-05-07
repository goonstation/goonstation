window.sizeHelper = {
	loaded: false,
	holderRef: '',
	interface: '',
	dataProp: '',

	loadMetas: function() { 
		var metas = document.getElementsByTagName('meta'); 

		for (var i = 0; i < metas.length; i++) { 
			if (metas[i].getAttribute('name') === 'holderRef') { 
				this.holderRef = metas[i].getAttribute('content');
			}

			if (metas[i].getAttribute('name') === 'interface') { 
				this.interface = metas[i].getAttribute('content');
			}

			if (metas[i].getAttribute('name') === 'dataProp') { 
				this.dataProp = metas[i].getAttribute('content');
			}
		} 
	},

	update: null,

	init: function() {
		this.loadMetas();

		if (typeof this.update === 'function') {
			this.update();
		}

		if (this.holderRef) {
			window.location = '?src=' + this.holderRef + ';action=loaded';
			this.loaded = true;
		}
	}
};
