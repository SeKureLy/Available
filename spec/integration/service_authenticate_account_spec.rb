describe 'Getting calendars' do
    describe 'Getting list of calendars' do
        before do 
            @account_data = DATA[:accounts][0]
            account = Available::Account.create(@account_data)
            account.add_owned_calendar(DATA[:calendars][0])
            account.add_owned_calendar(DATA[:calendars][1])
        end

        it 'HAPPY: should get list for authorized account' do
            auth = Available::AuthenticateAccount.call(
                username: @account_data['username'],
                password: @account_data['password']
            )

            header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
            get 'api/v1/calendars'
            _(last_response.status).must_equal 200

            result = JSON.parse last_response.body
            _(result['data'].count).must_equal 2
        end

        it 'BAD: should not process for unauthorized account' do
            header 'AUTHORIZATION', 'Bearer bad_token'
            get 'api/v1/calendars'
            _(last_response.status).must_equal 403

            result = JSON.parse last_response.body
            _(result['data']).must_be_nil
        end
    end