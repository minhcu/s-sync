import type Stripe from 'stripe'

export async function getStripeCustomerByEmail(email: string) {
  const { data: customers } = await stripeAdmin.customers.list({
    email,
  })

  return customers[0]
}

export function getStripeCustomerSubscriptions(customerId: string) {
  return stripeAdmin.subscriptions.list({
    customer: customerId,
    expand: [],
  })
}

export function createStripeCustomer(payload: {
  email: string
  phone?: string
  name?: string
}) {
  return stripeAdmin.customers.create({
    email: payload.email,
    phone: payload.phone,
    name: payload.name,
  })
}

export function updateStripeCustomer(customerId: string, customer: Stripe.CustomerUpdateParams) {
  return stripeAdmin.customers.update(customerId, customer)
}