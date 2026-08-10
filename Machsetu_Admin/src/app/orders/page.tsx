import { ORDERS, type OrderStage } from "@/lib/data";
import { rupees, rupeesShort, shortDate } from "@/lib/format";
import {
  Badge,
  Button,
  Card,
  CardHeader,
  PageHeader,
  Table,
  Td,
  Th,
  cx,
  statusTone,
} from "@/components/ui";

const STAGES: OrderStage[] = [
  "Inquiry Received",
  "Under Review",
  "Price Confirmed",
  "Machine Reserved",
  "Delivery Scheduled",
  "Delivered",
];

export default function OrdersPage() {
  const total = ORDERS.reduce((sum, o) => sum + o.amount, 0);
  const delivered = ORDERS.filter((o) => o.stage === "Delivered");
  const inFlight = ORDERS.length - delivered.length;

  return (
    <>
      <PageHeader
        title="Orders"
        subtitle="Confirmed procurements moving through escrow, logistics and handover."
        actions={<Button variant="secondary">Export ledger</Button>}
      />

      <div className="mb-4 grid gap-4 sm:grid-cols-3">
        <Card>
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            Total order value
          </p>
          <p className="mt-2 text-3xl font-extrabold text-navy-800">
            {rupeesShort(total)}
          </p>
          <p className="mt-1 text-xs text-faint">{ORDERS.length} orders</p>
        </Card>
        <Card>
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            In flight
          </p>
          <p className="mt-2 text-3xl font-extrabold text-accent-600">
            {inFlight}
          </p>
          <p className="mt-1 text-xs text-faint">Not yet delivered</p>
        </Card>
        <Card>
          <p className="text-xs font-bold tracking-wide text-muted uppercase">
            Delivered
          </p>
          <p className="mt-2 text-3xl font-extrabold text-emerald-600">
            {delivered.length}
          </p>
          <p className="mt-1 text-xs text-faint">
            {rupeesShort(delivered.reduce((s, o) => s + o.amount, 0))} settled
          </p>
        </Card>
      </div>

      <Card className="mb-4">
        <CardHeader
          title="Pipeline by stage"
          subtitle="Where every open order currently sits"
        />
        <div className="grid gap-3 sm:grid-cols-3 xl:grid-cols-6">
          {STAGES.map((stage) => {
            const items = ORDERS.filter((o) => o.stage === stage);
            return (
              <div
                key={stage}
                className={cx(
                  "rounded-lg border p-3.5",
                  items.length > 0
                    ? "border-navy-100 bg-navy-50/50"
                    : "border-line bg-white",
                )}
              >
                <p className="text-2xl font-extrabold text-navy-800">
                  {items.length}
                </p>
                <p className="mt-1 text-xs leading-snug font-semibold text-muted">
                  {stage}
                </p>
              </div>
            );
          })}
        </div>
      </Card>

      <Card padded={false}>
        <div className="p-5">
          <CardHeader
            title="All orders"
            subtitle="Newest first, across every buyer and seller"
          />
        </div>
        <Table>
          <thead>
            <tr>
              <Th>Order</Th>
              <Th>Machine</Th>
              <Th>Buyer</Th>
              <Th>Seller</Th>
              <Th>Stage</Th>
              <Th>Destination</Th>
              <Th className="text-right">Amount</Th>
              <Th className="text-right">Placed</Th>
              <Th className="w-20 text-right">Action</Th>
            </tr>
          </thead>
          <tbody>
            {ORDERS.map((o) => (
              <tr key={o.id} className="hover:bg-canvas/60">
                <Td className="font-bold whitespace-nowrap text-navy-800">
                  {o.id}
                </Td>
                <Td className="whitespace-nowrap">{o.machine}</Td>
                <Td className="whitespace-nowrap text-muted">{o.buyer}</Td>
                <Td className="whitespace-nowrap text-muted">{o.seller}</Td>
                <Td>
                  <Badge tone={statusTone(o.stage)} dot>
                    {o.stage}
                  </Badge>
                </Td>
                <Td className="whitespace-nowrap text-muted">
                  {o.destination}
                </Td>
                <Td className="text-right font-bold whitespace-nowrap text-navy-800">
                  {rupees(o.amount)}
                </Td>
                <Td className="text-right text-xs whitespace-nowrap text-muted">
                  {shortDate(o.placedOn)}
                </Td>
                <Td className="text-right">
                  <Button size="sm" variant="secondary">
                    Track
                  </Button>
                </Td>
              </tr>
            ))}
          </tbody>
        </Table>
      </Card>
    </>
  );
}
