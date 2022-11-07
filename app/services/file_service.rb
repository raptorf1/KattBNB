module FileService
  def self.generate_charge_succeeded_stripe_event(dates_string)
    {
      id: "evt_000000000000000000000000",
      object: "event",
      api_version: "2020-08-27",
      created: 1_648_320_032,
      data: {
        object: {
          id: "ch_000000000000000000000000",
          object: "charge",
          amount: 2000,
          amount_captured: 2000,
          amount_refunded: 0,
          application: nil,
          application_fee: nil,
          application_fee_amount: nil,
          balance_transaction: "txn_000000000000000000000000",
          billing_details: {
            address: {
              city: nil,
              country: nil,
              line1: nil,
              line2: nil,
              postal_code: nil,
              state: nil
            },
            email: nil,
            name: nil,
            phone: nil
          },
          calculated_statement_descriptor: "EXAMPLECOMPANY",
          captured: true,
          created: 1_648_320_032,
          currency: "usd",
          customer: nil,
          description: "(created by Stripe CLI)",
          destination: nil,
          dispute: nil,
          disputed: false,
          failure_code: nil,
          failure_message: nil,
          fraud_details: {
          },
          invoice: nil,
          livemode: false,
          metadata: {
            dates: dates_string,
            number_of_cats: 2,
            message: "very nice to do have my cat over to you",
            host_nickname: "JackTheReaper",
            price_per_day: 52.23,
            price_total: 250,
            user_id: 3
          },
          on_behalf_of: nil,
          order: nil,
          outcome: {
            network_status: "approved_by_network",
            reason: nil,
            risk_level: "normal",
            risk_score: 2,
            seller_message: "Payment complete.",
            type: "authorized"
          },
          paid: true,
          payment_intent: "pi_000000000000000000000000",
          payment_method: "pm_000000000000000000000000",
          payment_method_details: {
            card: {
              brand: "visa",
              checks: {
                address_line1_check: nil,
                address_postal_code_check: nil,
                cvc_check: nil
              },
              country: "US",
              exp_month: 3,
              exp_year: 2023,
              fingerprint: "ZoVSX2dK5igWt2SB",
              funding: "credit",
              installments: nil,
              last4: "4242",
              mandate: nil,
              network: "visa",
              three_d_secure: nil,
              wallet: nil
            },
            type: "card"
          },
          receipt_email: nil,
          receipt_number: nil,
          receipt_url:
            "https://pay.stripe.com/receipts/acct_0000000000000000/ch_000000000000000000000000/rcpt_0000000000000000000000000000000",
          refunded: false,
          refunds: {
            object: "list",
            data: [],
            has_more: false,
            total_count: 0,
            url: "/v1/charges/ch_000000000000000000000000/refunds"
          },
          review: nil,
          shipping: {
            address: {
              city: "San Francisco",
              country: "US",
              line1: "510 Townsend St",
              line2: nil,
              postal_code: "94103",
              state: "CA"
            },
            carrier: nil,
            name: "Jenny Rosen",
            phone: nil,
            tracking_number: nil
          },
          source: nil,
          source_transfer: nil,
          statement_descriptor: nil,
          statement_descriptor_suffix: nil,
          status: "succeeded",
          transfer_data: nil,
          transfer_group: nil
        }
      },
      livemode: false,
      pending_webhooks: 2,
      request: {
        id: "req_00000000000000",
        idempotency_key: "7143a956-2f40-407a-b312-43038ae76c86"
      },
      type: "charge.succeeded"
    }.to_json
  end
end
