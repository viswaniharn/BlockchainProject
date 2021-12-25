App = {
  web3Provider: null,
  contracts: {},
  names: new Array(),
  url: 'http://127.0.0.1:7545',
  chairPerson:null,
  currentAccount:null,
  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
        // Is there is an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fallback to the TestRPC
      App.web3Provider = new Web3.providers.HttpProvider(App.url);
    }
    web3 = new Web3(App.web3Provider);

    ethereum.enable();

    return App.initContract();
  },

  initContract: function() {
      $.getJSON('../Royalties.json', function(data) {
    // Get the necessary contract artifact file and instantiate it with truffle-contract
    var royaltyArtifact = data;
    App.contracts.royalty = TruffleContract(royaltyArtifact);

    // Set the provider for our contract
    App.contracts.royalty.setProvider(App.web3Provider);
    
    new Web3(new Web3.providers.HttpProvider(App.url)).eth.getAccounts((err, accounts) => {
      App.chairPerson = accounts[0];
    });

    App.changeVisibility();
    App.populateAddress();
    App.handleDisplayTalentPieces();
    App.handleCurrentAddress();
    return App.bindEvents();
  });
  },

  bindEvents: function() {
    $(document).on('click', '#register', function(){ var ad = $('#enter_address').val(); App.handleRegister(ad); });
    $(document).on('click', '#unregister', function(){ var ad = $('#enter_address').val(); App.handleUnregister(ad); });
    $(document).on('click', '#create_talent_piece', function(){ App.handleCreateTalentPiece(); });
    $(document).on('click', '#use_talent_piece', function(){ App.useTalentPiece(); });
    $(document).on('click', '#get_talent_piece', function() {App.getTalentPiece();})
    $(document).on('click', '#get_talent_piece_used', function() {App.getTalentPieceUsed();})
  },

  handleCurrentAddress: function() {
    $('#current_address').empty().append(web3.eth.coinbase);
  },

  handleDisplayTalentPieces: function() {
    var royaltyInstance;
    web3.eth.getAccounts(function(error, accounts) {
      var account = accounts[0];
      App.contracts.royalty.deployed().then(function(instance) {
        royaltyInstance = instance;
        return royaltyInstance.getNames({from: account});
      }).then(function(result, err) {
        console.log(result)
        jQuery.each(result, function(i) {
          if( i!= 0 ) {
            console.log(result[i]);
            var displayName = '<li>' + result[i] + '</li>';
            jQuery('#list_of_talents').append(displayName);
          }
        })
      });
    });
  },

  getTalentPiece: function() {
    var royaltyInstance;
    web3.eth.getAccounts(function(error, accounts) {
      var account = accounts[0];
      App.contracts.royalty.deployed().then(function(instance) {
        royaltyInstance = instance;
        var index = $('#get_talent_piece_index').val();
        console.log(index);
        return royaltyInstance.getData(index, {from: account});
      }).then(function(result, err) {
        console.log(result);
        $('#data_index').empty();
        var displayData = '</br><span> Name: ' + result[1] + '</span></br>';
        displayData = displayData + '<span> Description: ' + result[2] + '</span></br>';
        displayData = displayData + '<span> Cost: ' + result[3] + '</span></br>';
        displayData = displayData + '<span> Limit: ' + result[4] + '</span></br>';
        $('#data_index').append(displayData);
      });
    })
  },

  getTalentPieceUsed: function() {
    web3.eth.getAccounts(function(error, accounts) {
      var account = accounts[0];
      App.contracts.royalty.deployed().then(function(instance) {
        royaltyInstance = instance;
        var index = $('#get_talent_piece_used_index').val();
        console.log(index);
        return royaltyInstance.numberOfTimesUsed(index, {from: account});
      }).then(function(result, err) {
        console.log(result);
        $('#data_index_used').empty().append('</br><span> Number of times the talent has been used: ' + result + '</span>');
      });
    })
  },

  populateAddress : function(){
    new Web3(new Web3.providers.HttpProvider(App.url)).eth.getAccounts((err, accounts) => {
      web3.eth.defaultAccount=web3.eth.accounts[0]
      jQuery.each(accounts,function(i){
        if(web3.eth.coinbase != accounts[i] && App.chairPerson != accounts[i]){
          var optionElement = '<option value="'+accounts[i]+'">'+accounts[i]+'</option';
          jQuery('#enter_address').append(optionElement);  
        }
      });
      var optionElement = '<option value="0">Talent Piece Owner</option>';
      jQuery('#user_type').append(optionElement);
      optionElement = '<option value="1">Talent Piece User</option>';
      jQuery('#user_type').append(optionElement);
    });
  },

  handleRegister: function(addr){
    var royaltyInstance;
    web3.eth.getAccounts(function(error, accounts) {
      var account = accounts[0];
      App.contracts.royalty.deployed().then(function(instance) {
        royaltyInstance = instance;
        var type;
        var user_type = $('#user_type').val();
        if(user_type == "0") {
          type = true;
        } else {
          type = false;
        }
        return royaltyInstance.registerTalentPieceOwner(addr, type, {from: account});
    }).then(function(result, err){
        if(result){
            if(parseInt(result.receipt.status) == 1)
            alert(addr + " registration done successfully")
            else
            alert(addr + " registration not done successfully due to revert")
        } else {
            alert(addr + " registration failed")
        }   
      })
    })
  },

  handleUnregister: function(addr){
    var royaltyInstance;
    web3.eth.getAccounts(function(error, accounts) {
      var account = accounts[0];
      App.contracts.royalty.deployed().then(function(instance) {
        royaltyInstance = instance;
        return royaltyInstance.unregisterTalentPieceOwner(addr, {from: account});
    }).then(function(result, err){
        if(result){
            if(parseInt(result.receipt.status) == 1)
            alert(addr + " unregistration done successfully")
            else
            alert(addr + " unregistration not done successfully due to revert")
        } else {
            alert(addr + " unregistration failed")
        }   
      })
    })
  },

  handleCreateTalentPiece: function() {
    var royaltyInstance;
    web3.eth.getAccounts(function(error, accounts) {
      var account = accounts[0];
      App.contracts.royalty.deployed().then(function(instance) {
        royaltyInstance = instance;
        var name = $('#talent_piece_name').val();
        var description = $('#talent_piece_description').val();
        var cost = $('#talent_piece_cost').val();
        var limit = $('#talent_piece_limit').val();
        console.log(name);
        console.log(description);
        console.log(cost);
        console.log(limit);
        return royaltyInstance.createTalentPiece(name, description, cost, limit , {from: web3.eth.coinbase});
      })
    })
  },

  useTalentPiece: function() {
    var royaltyInstance;
    web3.eth.getAccounts(function(error, accounts) {
      var account = accounts[0];
      App.contracts.royalty.deployed().then(function(instance) {
        royaltyInstance = instance;
        var index = $('#talent_piece_index').val();
        console.log(index);
        return royaltyInstance.useTalentPiece(index, {from: web3.eth.coinbase});
    }).then(function(result, err){
        if(result){
            if(parseInt(result.receipt.status) == 1)
            alert(" use done successfully");
            else
            alert(" use not done successfully due to revert");
        } else {
            alert(" use failed");
        }   
      })
    })
  },

  changeVisibility: function() {
    web3.eth.getAccounts(function(error, accounts) {
      var account = accounts[0];
      if(App.chairPerson == account) {
        $("#admin_div").css("visibility", "visible");
      } else {
        $("#admin_div").css("visibility", "hidden");
      }
    })
  }

};
// code for reloading the page on account change
window.ethereum.on('accountsChanged', function (){
  location.reload();
})

$(function() {
  $(window).load(function() {
    App.init();
  });
});
